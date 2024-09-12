function new_plotHazardPSTH(data,axs)
%% Plot the mean time-courses of each neuron for the two different hazard rates
% when aligned to multiple different events

if isempty(axs)
    figure; hold on;
end
% else
%     axes(ax); hold on;
% end

n_units = length(data.spikes.id);
n_trials = size(data.spikes.data,1);
hazards = nonanunique(data.values.hazard);
if length(hazards) > 1
    hazard_leg = {[num2str(hazards(1)) ' Hazard'],[ num2str(hazards(2)) ' Hazard']};
else
    hazard_leg = {[num2str(hazards(1)) ' Hazard']};
end
window_width = 1000;
codes = {'sample_on','sac_on'};  %'fp_off','target_off',
co = {[4 94 167]./255, [194 0 77]./255};
p=[];
for u = 1:n_units
   % figure_handle(u) = figure; hold on;
    for c = 1:length(codes)
        event_code = codes{c};
        for h = 1:length(hazards)
            if isempty(axs)
                axs = subplot(2,1,c); hold on;
            else
                %axes(ax(c)); hold on;
                ax = axs(c); hold on;
            end
           % title(['U: ', num2str(data.spikes.id(u))]);
            criteria = data.values.hazard==hazards(h) & data.values.score_match == 1; % only correct trials
            tmp.binned_spikes = squeeze(data.binned_spikes(u,:,criteria));
            tmp.ecodes = data.values(criteria,:);
            tmp.times = data.times(criteria,:);
            p(h) = new_plotPSTHAligned(tmp,event_code,window_width,ax,co{h},1);
        end
        if isempty(axs)
            filename = data.data.header.filename;
            startIdx = strfind(filename, 'MM');
            endIdx = strfind(filename, '.hdf5') - 1;
            sessionName = filename(startIdx:endIdx);
            sgtitle([sessionName ' Unit: ' num2str(data.spikes.id(u))], 'Interpreter', 'none');
            legend(p,hazard_leg)
        else
            title('All Cue Locations')
            if c == 1
                legend(p,hazard_leg)
            end
        end
%         legend(p,cellstr(num2str(hazards)))
%         sgtitle([data.fileName ' Unit: ' num2str(data.spikes.id(u))], 'Interpreter', 'none');
    end
end
