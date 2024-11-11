function figure_handle = plotPolarTask(data,u,axs)
%% 
% data: 1 x 1 struct with 8 fields for a session
% u: current unit id to plot
% axs: current axes to use for plotting

if isempty(axs)
    figure; hold on;
end

%n_units = length(data.spikes.unit);
%determine the unique sample locations
%decide time windows


%ids of the 9 unique possible samples (in 9 different locations)
%sample_loc = nonanunique(data.ecodes.sample_id);

sample_cord(:,1) = data.values.t1_x(isnan(data.values.hazard));
sample_cord(:,2) = data.values.t1_y(isnan(data.values.hazard));
sample_loc = unique(sample_cord, 'rows');
%sample_loc = sample_loc(~isnan(sample_loc));
sample_loc(any(isnan(sample_loc),2),:) = [];
n_samples = size(sample_loc,1);

%300ms
alignments = {'sample_on','sac_on'};
window_length = 300;

loc_data = cell(1,n_samples);
loc_ecodes = cell(1,n_samples);
loc_timing = cell(1,n_samples);

p=[];


% Check whether T1 (ODR) was performed, and if so, ensure you have at least
% 3 trials for each sample/target location. 
if ~ismember(1,data.ids.task_id) || ~(sum(data.ids.task_id == 1)> 3*length(sample_loc))
    fprintf('\nNo T1 ODR task or too few trials\n')
    figure_handle = 0; 
else
    %loop through units
    %for u = 1:n_units
    %figure_handle(u) = figure; hold on;

    %loop through different time windows
    for t = 1:length(alignments)
        %loop through different sample locations (8 possible)

        if ~isempty(axs)
            ax = axs(t); hold on;
        end

        for s = 1:length(sample_loc)
            criteria = data.ids.task_id == 1 & data.values.t1_x==sample_loc(s,1) & data.values.t1_y==sample_loc(s,2) & data.ids.score == 1;  %select trials with specified sample and correct
            if sum(criteria)==0
                fprintf('No trials where task_id = 1, t1_x = %f, t1_y = %f, and choice was correct\n', sample_loc(s,1), sample_loc(s,2));
                continue
            end
            loc_data{s} = squeeze(data.spike_time_mat(u,:,criteria));
            loc_ecodes{s} = data.values(criteria,:);
            loc_timing{s} = data.times(criteria,:);
        end

        if all(cellfun(@isempty, loc_data))
            disp("No data to plot for plotPolarTask");
            continue
        end

        %ax = subplot(1,3,t);hold on;
        id = num2str(data.spikes.id(u));
        p(t) = plotPolarAlignedT(loc_data,loc_ecodes,loc_timing,alignments(t),window_length,t,ax);

        if isempty(axs)
            filename = data.data.header.filename;
            startIdx = strfind(filename, 'MM');
            endIdx = strfind(filename, '.hdf5') - 1;
            sessionName = filename(startIdx:endIdx);
            sgtitle([sessionName ' Unit: ' num2str(data.spikes.id(u)) ' Firing Rate'],'Interpreter', 'none')
        end
    end
    %end
end


end