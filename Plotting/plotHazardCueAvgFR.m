function plotHazardCueAvgFR(data,u,axs)
%% Plot the mean time-courses of each neuron for the two different hazard rates
% when aligned to multiple different events
% data: 1 x 1 struct with 8 fields for a session
% u: current unit id to plot
% axs: current axes to use for plotting

if isempty(axs)
    figure; hold on;
end

n_units = length(data.spikes.id);
%n_trials = data.header.numTrials;
hazards = nonanunique(data.values.hazard);
if length(hazards)>1
    hazard_leg = {[num2str(hazards(1)) ' Hazard'],[ num2str(hazards(2)) ' Hazard']};
else
    hazard_leg = {[num2str(hazards(1)) ' Hazard']};
end
window_size = 300;  %could adjust
alignments = {'sample_on','sac_on'};  %'fp_off','target_off',

cue_locs = nonanunique(data.ids.sample_id);
co = {[4 94 167]./255, [194 0 77]./255};
%p=[];
   
for a = 1:length(alignments)
    alignment = alignments{a};
    if isempty(axs)
        subplot(2,1,a); hold on;
    else
        %axes(ax(c)); hold on;
        ax = axs(a); hold on;
        axes(ax); hold on;
    end
    
    for h = 1:length(hazards)
        fr_cue = NaN(1,length(cue_locs)); %firing rate for each cue location
        std_cue = NaN(1,length(cue_locs)); %standard deviation for each cue location
        error_cue = NaN(1,length(cue_locs)); %standard error for each cue location
        for c = 1:length(cue_locs)
            criteria = data.values.hazard==hazards(h) & data.ids.sample_id==cue_locs(c) & ~isnan(data.times.sac_on) & ~isnan(data.times.(char(alignment)));
            %tmp.spikes = squeeze(data.spikes.data(criteria,:));
            tmp.spikes = squeeze(data.binned_spikes(u,:,criteria));
            tmp.ecodes = data.values(criteria,:);
            times_table = data.times(criteria,:);
            times_array = table2array(times_table)*1000; %convert to ms
            tmp.timing = array2table(times_array, 'VariableNames', times_table.Properties.VariableNames);
            
            if strcmp(char(alignment), 'sample_on')
                start_t = tmp.timing.(char(alignment)); %start times for this sample
                end_t = start_t+window_size;
            elseif strcmp(char(alignment), 'sac_on')
                end_t = tmp.timing.(char(alignment)); %end times for this sample
                start_t = end_t-window_size;
            end
            
            
            fr_trial = NaN(1,length(tmp.ecodes.trial_num)); %struct for firing of each trial
            %loop through each trial
            for t = 1:length(tmp.ecodes.trial_num)
                if size(tmp.spikes,1) < round(start_t(t))
                    % a unique instance where no spikes were recorded
                    % beyond this time. thus FRs is 0
                    fr_trial(t) = 0;
                elseif size(tmp.spikes,1) < round(end_t(t))
                    % a unique instance where no spikes were recorded
                    % beyond this time,
                    frs =  tmp.spikes(round(start_t(t)):end,t);
                    fr_trial(t) = sum(frs)/((round(end_t(t))-round(start_t(t))));
                else
                    if isnan(round(start_t(t)))
                        disp(num2str(t));
                    end
                    frs =  tmp.spikes(round(start_t(t)):round(end_t(t)),t);
                    fr_trial(t) = sum(frs)/((round(end_t(t))-round(start_t(t))));
                    %                     spikes_cur = tmp.spikes(t);
                    %                     criteria_st = spikes_cur{1}>start_t(t); %index of spikes that occur after the start time
                    %                     criteria_en = spikes_cur{1}<end_t(t); %index of spikes that occur before the end time
                    %                     sp_ind = criteria_st.*criteria_en; %index of spikes that occur within the time window
                    %                     fr_trial(t) = sum(sp_ind)/((end_t(t)-start_t(t))*.001); %fr rate for this trial in spikes/second
                end
            end
            fr_cue(c) =  nanmean(fr_trial); %mean(fr_trial,[],'omitnan');
            std_cue(c) = nanstd(fr_trial); %std(fr_trial,[],'omitnan');
            error_cue(c) = std_cue(c)/sqrt(length(fr_trial));
        end
        
        
        % plot(cue_locs,fr_cue)
        
        errorbar(cue_locs, fr_cue,error_cue, 'o-', 'MarkerFaceColor', co{h}, 'MarkerSize', 5, 'LineWidth', 1);
        hold on;
        
    end
    ylabel('Firing Rate (sp/s)')
    xlabel('Cue Location')
    if isempty(axs)
        title(['Aligned to ' alignment],'Interpreter', 'none')
        %filename = data.data.header.filename;
        filename = data.fileName;
        startIdx = strfind(filename, 'MM');
        endIdx = strfind(filename, '.hdf5') - 1;
        sessionName = filename(startIdx:endIdx);
        title([sessionName ' U: ' num2str(data.spikes.id(u)) 'Aligned to ' alignment],'Interpreter', 'none')
        legend(hazard_leg)
    else
        if a == 1
            legend(hazard_leg)
        end
        title(['Aligned to ' alignment],'Interpreter', 'none')
    end
end