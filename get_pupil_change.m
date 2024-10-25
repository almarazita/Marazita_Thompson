function all_evoked_pupil = get_pupil_change(all_pyr_cleaned_data)
%% Use the pupil change definition to compute the evoked pupil response.
% Author: ChatGPT

%% 1) Visualize each experiment's average pupil response
% Before computing pupil change, see what the response looks like. Are
% there peaks and troughs?
num_sessions = length(all_pyr_cleaned_data); % Number of sessions

% Initialize figure
figure;
num_rows = ceil(num_sessions / 3);
num_cols = min(num_sessions, 3);

% Preallocate mean and SEM for all sessions
mean_pupil = cell(num_sessions, 1);
sem_pupil = cell(num_sessions, 1);

% Plot each session
for i = 1:num_sessions
    cur_session = all_pyr_cleaned_data{i};
    % Compute mean and standard error of the mean (SEM)
    mean_pupil{i} = nanmean(cur_session.cleaned_pupil, 1); % Mean across trials
    sem_pupil{i} = nanstd(cur_session.cleaned_pupil, 0, 1) ./ sqrt(sum(~isnan(cur_session.cleaned_pupil), 1)); % SEM

    % Plot
    subplot(num_rows, num_cols, i);
    max_frames = size(cur_session.cleaned_pupil, 2);
    time_vector = (1:max_frames); % Time in frames (modify if needed)
   
    % Plot the mean response
    hold on;
    fill([time_vector fliplr(time_vector)], ...
        [mean_pupil{i} + sem_pupil{i}; flipud(mean_pupil{i} - sem_pupil{i})], ...
        [0.8 0.8 0.8], 'EdgeColor', 'none'); % Grey shaded error bands
    plot(time_vector, mean_pupil{i}, 'k', 'LineWidth', 2); % Mean response

    % Add vertical lines and arrows for sample on
    num_trials = cur_session.header.numTrials;
    for tr = 1:num_trials
        sample_on = new_getEventIndex(cur_session, tr, 19); % Replace with your function
        if ~isnan(sample_on)
            plot([sample_on sample_on], ylim, 'k--'); % Dashed vertical line
            annotation('arrow', [sample_on/max_frames sample_on/max_frames], ...
                       [0.85 0.95], 'Color', 'k'); % Downward arrow
            text(sample_on, ylim(2) * 0.95, 'Sample on', 'Color', 'k', 'HorizontalAlignment', 'center');
        end
    end

    % Set axis labels
    xlabel('Time (ms)');
    ylabel('Pupil diameter (z-scored)');
    filename = cur_session.header.filename;
    startIdx = strfind(filename, 'MM');
    endIdx = strfind(filename, '.hdf5') - 1;
    sessionName = filename(startIdx:endIdx);
    title(sessionName, 'Interpreter', 'none');
    hold off;
end

% % Average across all sessions
% all_sessions_data = cell2mat(cellfun(@(x) x, mean_pupil, 'UniformOutput', false));
% mean_all_sessions = nanmean(all_sessions_data, 1);
% sem_all_sessions = nanstd(all_sessions_data, 0, 1) ./ sqrt(sum(~isnan(all_sessions_data), 1));
% 
% % Plot overall average
% figure;
% hold on;
% fill([time_vector fliplr(time_vector)], ...
%     [mean_all_sessions + sem_all_sessions; flipud(mean_all_sessions - sem_all_sessions)], ...
%     [0.8 0.8 0.8], 'EdgeColor', 'none'); % Grey shaded error bands
% plot(time_vector, mean_all_sessions, 'k', 'LineWidth', 2); % Mean response
% 
% % Add vertical lines and arrows for sample on (example for first session)
% for tr = 1:num_trials
%     sample_on = new_getEventIndex(cur_session, tr, 19); % Replace with your function
%     if ~isnan(sample_on) && sample_on <= frames
%         plot([sample_on sample_on], ylim, 'k--'); % Dashed vertical line
%         annotation('arrow', [sample_on/frames sample_on/frames], ...
%                    [0.85 0.95], 'Color', 'k'); % Downward arrow
%         text(sample_on, ylim(2) * 0.95, 'Sample on', 'Color', 'k', 'HorizontalAlignment', 'center');
%     end
% end
% 
% % Set axis labels
% xlabel('Time (ms)');
% ylabel('Pupil diameter (z-scored)');
% title('Average across all sessions');
% hold off;