function figure_handle = plotPolarTask(data,u,axs)
%%
% data: 1 x 1 struct with 8 fields for a session
% u: current unit id to plot
% axs: current axes to use for plotting

if isempty(axs)
    figure; hold on;
end

%ids of the 8 unique possible samples (in 8 different locations)
sample_cord(:,1) = data.values.t1_x(isnan(data.values.hazard));
sample_cord(:,2) = data.values.t1_y(isnan(data.values.hazard));
sample_loc = unique(sample_cord, 'rows');
sample_loc(any(isnan(sample_loc),2),:) = [];
sample_thetas = cart2pol(sample_loc(:,1), sample_loc(:,2));
n_samples = size(sample_loc,1);
alignments = {'sample_on','sac_on'};
p=[];

% Check whether T1 (ODR) was performed, and if so, ensure you have at least
% 3 trials for each sample/target location.
if ~ismember(1,data.ids.task_id) || ~(sum(data.ids.task_id == 1)> 3*length(sample_loc))
    fprintf('\nNo T1 ODR task or too few trials\n')
    figure_handle = 0;
else
    %loop through different time windows
    for t = 1:length(alignments)
        if ~isfield(data,'epochs') % check if data already has window averages
            data.epochs = epochData(data,1,1);
        end

        %loop through different sample locations (8 possible)
        if ~isempty(axs)
            ax = axs(t); hold on;
        end
        loc_data = nan(n_samples,1);
        for s = 1:length(sample_loc)
            % find indices of relevant trials
            criteria = data.ids.task_id == 1 & data.values.t1_x==sample_loc(s,1) & data.values.t1_y==sample_loc(s,2) & data.ids.score == 1;  %select trials with specified sample and correct
            if sum(criteria)==0
                fprintf('No trials where task_id = 1, t1_x = %f, t1_y = %f, and choice was correct\n', sample_loc(s,1), sample_loc(s,2));
                continue
            end
            % Polar plots can't go negative, so check if epochs are
            % baseline subtracted
            if data.epochs.is_bs
                % add back baseline for polar plots
                if t == 1 % sample on alignment
                    loc_data(s) = mean(data.epochs.target_on(u,criteria) + ...
                        data.epochs.baseline(u,criteria)); 
                else
                    loc_data(s) = mean(data.epochs.saccade_on(u,criteria) + ...
                        data.epochs.baseline(u,criteria));
                end
            else
                if t == 1 % sample on alignment
                    loc_data(s) = mean(data.epochs.target_on(u,criteria)); %squeeze(data.spike_time_mat(u,:,criteria));
                else
                    loc_data(s) = mean(data.epochs.saccade_on(u,criteria));
                end
            end
        end

        %% Now plot
        % Polar plots are weird, may need some modifications
        if isempty(ax)
            figure; hold on;
        else
            axPosition = get(ax, 'Position');
            axXLim = get(ax, 'XLim');
            axYLim = get(ax, 'YLim');

            % Create a polar axes at the same position
            pax = polaraxes('Position', axPosition);

            % Set the limits of the polar axes to match the Cartesian axes
            set(pax, 'RLim', axYLim);
            set(pax, 'ThetaLim', axXLim);

            % Copy the children (e.g., plots, labels) from the original axes to the polar axes
            copyobj(get(ax, 'Children'), pax);

            delete(ax);

        end
        wrapped_thetas = wrapTo2Pi(sample_thetas);
        [wrapped_thetas, sort_inds] = sort(wrapped_thetas);
        loc_data = loc_data(sort_inds);
        % repeat the first value to connect the line
        wrapped_thetas(end+1) = wrapped_thetas(1);
        loc_data(end+1) = loc_data(1);
        p = polarplot(pax,wrapped_thetas,loc_data,'bo-', 'MarkerSize', 8, 'LineWidth', 1.5, 'MarkerFaceColor', 'blue');
        title(['Aligned to ' char(alignments{t})],'Interpreter', 'none')

        %% Title
        if isempty(axs)
            filename = data.data.header.filename;
            startIdx = strfind(filename, 'MM');
            endIdx = strfind(filename, '.hdf5') - 1;
            sessionName = filename(startIdx:endIdx);
            sgtitle([sessionName ' Unit: ' num2str(data.spikes.id(u)) ' Firing Rate'],'Interpreter', 'none')
        end
    end
end


end