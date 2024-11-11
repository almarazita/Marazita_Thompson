function plotCueLocPSTH(data,u,axs,cue)
%% Plot the PSTH for specific cue locations across hazards 
% when aligned to multiple different events
%Input: 
% data: 1 x 1 struct with 8 fields for a session
% u: current unit id to plot
% axs: current axes to use for plotting
% cue: sample ID for the cue location of interest (0 is center,
% going from -4 to 4) can be a vector with up to 4 IDS

if isempty(axs)
    figure; hold on;
end


cues = NaN(1,6);

for i=1:length(cues)
    if length(cue)>=i
        cues(i) = cue(i);
    else
        cues(i) = cue(1);
    end
end


%n_units = length(data.spikes.unit);
cue_loc = data.ids.sample_id; 
hazards = nonanunique(data.values.hazard);
if length(hazards) > 1
    hazard_leg = {[num2str(hazards(1)) ' Hazard'],[ num2str(hazards(2)) ' Hazard']};
else
    hazard_leg = {[num2str(hazards(1)) ' Hazard']};
end

window_width = 1000;
codes = {'sample_on','sac_on'};  %'fp_off','target_off'
co = {[4 94 167]./255, [194 0 77]./255};
p=[];

% figure_handle(u) = figure; hold on;
for c = 1:length(codes)
    event_code = codes{c};
    for h = 1:length(hazards)
        if isempty(axs)
            axs = subplot(2,1,c); hold on;
        else
            ax = axs(c); hold on;
        end

       % ax = subplot(2,1,c); hold on;
        %title(['U: ', num2str(data.spikes.id(u))]);
        criteria = data.values.hazard==hazards(h) & (cue_loc==cues(1) | cue_loc == cues(2) | cue_loc == cues(3)| cue_loc == cues(4)| cue_loc == cues(5)| cue_loc == cues(6));
        tmp.binned_spikes = squeeze(data.binned_spikes(u,:,criteria));
        tmp.ecodes = data.values(criteria,:);
        tmp.times = data.times(criteria,:);
        p(h) = plotPSTHAligned(tmp,event_code,window_width,ax,co{h},1);
        if ~isempty(axs)
            title(['Cue Location ' num2str(cue)], 'Interpreter', 'none');
        end
    end
    if isempty(axs)
        filename = data.header.filename;
        startIdx = strfind(filename, 'MM');
        endIdx = strfind(filename, '.hdf5') - 1;
        sessionName = filename(startIdx:endIdx);
        sgtitle([sessionName ' Cue Location ' num2str(cue) ' U: ' num2str(data.spikes.id(u))], 'Interpreter', 'none');
        legend(p,hazard_leg)
%         elseif c == 1
%             legend(p,hazard_leg)
    end 
end