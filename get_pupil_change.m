function all_evoked_pupil = get_pupil_change(all_pyr_cleaned_data, will_plot)
%% Use the pupil change definition to compute the evoked pupil response.

% Default to not plotting
if nargin < 2
    will_plot = false;
end

%% 1) Visualization
% if will_plot
%     % Visualize each experiment's average pupil response
%     % Before computing pupil change, see what the response looks like. Are
%     % there peaks and troughs?
%     num_sessions = length(all_pyr_cleaned_data); % Number of sessions
% 
%     % Preallocate mean and SEM for all sessions
%     mean_pupil = cell(num_sessions, 1);
%     sem_pupil = cell(num_sessions, 1);
%     high_h_mean_pupil = cell(num_sessions, 1);
%     high_h_sem_pupil = cell(num_sessions, 1);
%     low_h_mean_pupil = cell(num_sessions, 1);
%     low_h_sem_pupil = cell(num_sessions, 1);
% 
%     % Plot each session
%     for i = 1:num_sessions
%         % Create multiple 3 x 3 figures
%         subplot_num = mod(i, 9);
%         if subplot_num == 1
%             figure;
%         end
%         if subplot_num == 0
%             subplot_num = 9;
%         end
%         subplot(3, 3, subplot_num)
% 
%         % Get session
%         cur_session = all_pyr_cleaned_data{i};
% 
%         % Align cleaned pupil data to cue onset
%         num_trials = cur_session.header.numTrials;
%         evoked_traces = cell(num_trials, 1);
%         for tr = 1:num_trials
%             if ~all(isnan(cur_session.cleaned_pupil(tr, :))) % Will need to change after new cleaning
%                 sample_on_idx = new_getEventIndex(cur_session, tr, 19);
%                 evoked_traces{tr} = cur_session.cleaned_pupil(tr, sample_on_idx-300:end);
%             end
%         end
%         % Convert to matrix
%         max_frames = max(cellfun(@length, evoked_traces));
%         evoked_trace_mat = nan(num_trials, max_frames);
%         for tr = 1:num_trials
%             cur_response = evoked_traces{tr};
%             evoked_trace_mat(tr, 1:length(cur_response)) = cur_response;
%         end
% 
%         % Compute mean and standard error of the mean (SEM)
%         mean_pupil{i} = nanmean(evoked_trace_mat, 1); % Mean across trials
%         sem_pupil{i} = nanstd(evoked_trace_mat, 0, 1) ./ sqrt(sum(~isnan(evoked_trace_mat), 1)); % SEM
%         % By switch rate
%         high_h_tr = cur_session.values.hazard == 0.50;
%         low_h_tr = cur_session.values.hazard == 0.05;
%         high_h_mean_pupil{i} = nanmean(evoked_trace_mat(high_h_tr, :), 1);
%         high_h_sem_pupil{i} = nanstd(evoked_trace_mat(high_h_tr, :), 0, 1) ./ sqrt(sum(~isnan(evoked_trace_mat(high_h_tr, :)), 1));
%         low_h_mean_pupil{i} = nanmean(evoked_trace_mat(low_h_tr, :), 1);
%         low_h_sem_pupil{i} = nanstd(evoked_trace_mat(low_h_tr, :), 0, 1) ./ sqrt(sum(~isnan(evoked_trace_mat(low_h_tr, :)), 1));
% 
%         % Check for missing values
%         % DELETE AFTER NEW PUPIL CLEANING IS DONE
%         if sum(isnan(mean_pupil{i})) > 0
%             nan_loc = find(isnan(mean_pupil{i}));
%             if all(diff(nan_loc) > 0)
%                 mean_pupil{i}(nan_loc(1):end) = [];
%                 sem_pupil{i}(nan_loc(1):end) = [];
%                 disp('Discarded final all-NaN frames in mean evoked response.')
%             else
%                 disp('Frames with all NaN values in pupil data.')
%                 return
%             end
%         end
% 
%         % Plot overall mean response
%         hold on;
%         upper = mean_pupil{i}(1:1301) + sem_pupil{i}(1:1301);
%         lower = mean_pupil{i}(1:1301) - sem_pupil{i}(1:1301);
%         xaxis = [-300:1000];
%         fill([xaxis xaxis(end:-1:1)], [upper lower(end:-1:1)],...
%             [0.5 0.5 0.5], 'EdgeColor', 'none', 'FaceAlpha', 0.3);
%         plot(xaxis, mean_pupil{i}(1:1301), 'k', 'LineWidth', 2);
% 
%         % By switch rate
%         % Plot
%         hold on;
%         upper = high_h_mean_pupil{i}(1:1301) + high_h_sem_pupil{i}(1:1301);
%         lower = high_h_mean_pupil{i}(1:1301) - high_h_sem_pupil{i}(1:1301);
%         fill([xaxis xaxis(end:-1:1)], [upper lower(end:-1:1)],...
%             [194 0 77]./255, 'EdgeColor', 'none', 'FaceAlpha', 0.3);
%         plot(xaxis, high_h_mean_pupil{i}(1:1301), 'color', [194 0 77]./255, 'LineWidth', 2);
% 
%         upper = low_h_mean_pupil{i}(1:1301) + low_h_sem_pupil{i}(1:1301);
%         lower = low_h_mean_pupil{i}(1:1301) - low_h_sem_pupil{i}(1:1301);
%         fill([xaxis xaxis(end:-1:1)], [upper lower(end:-1:1)],...
%             [4 94 167]./255, 'EdgeColor', 'none', 'FaceAlpha', 0.3);
%         plot(xaxis, low_h_mean_pupil{i}(1:1301), 'color', [4 94 167]./255, 'LineWidth', 2);
% 
%         % Set axis labels
%         xline(0, '--k');
%         xlim([-300 1000]);
%         xlabel('Time wrt Cue Onset (ms)');
%         ylabel('Pupil diameter (z-scored)');
%         filename = cur_session.header.filename;
%         startIdx = strfind(filename, 'MM');
%         endIdx = strfind(filename, '.hdf5') - 1;
%         sessionName = filename(startIdx:endIdx);
%         title(sessionName, 'Interpreter', 'none');
%         hold off;
%     end
% 
%     %% Visualize the population pupil response
%     % First convert everything to matrices
%     max_frames = max(cellfun(@length, mean_pupil));
%     mean_pupil_mat = nan(num_sessions, max_frames);
%     max_frames = max(cellfun(@length, high_h_mean_pupil));
%     high_h_mean_pupil_mat = nan(num_sessions, max_frames);
%     max_frames = max(cellfun(@length, low_h_mean_pupil));
%     low_h_mean_pupil_mat = nan(num_sessions, max_frames);
%     for i = 1:num_sessions
%         cur_response = mean_pupil{i};
%         mean_pupil_mat(i, 1:length(cur_response)) = cur_response;
%         cur_response = high_h_mean_pupil{i};
%         high_h_mean_pupil_mat(i, 1:length(cur_response)) = cur_response; 
%         cur_response = low_h_mean_pupil{i};
%         low_h_mean_pupil_mat(i, 1:length(cur_response)) = cur_response; 
%     end
% 
%     % Average across sessions by switch rate
%     pop_avg = nanmean(mean_pupil_mat, 1);
%     pop_sem = nanstd(mean_pupil_mat, 0, 1) ./ sqrt(sum(~isnan(mean_pupil_mat), 1));
%     high_h_pop_avg = nanmean(high_h_mean_pupil_mat, 1);
%     high_h_pop_sem = nanstd(high_h_mean_pupil_mat, 0, 1) ./ sqrt(sum(~isnan(high_h_mean_pupil_mat), 1));
%     low_h_pop_avg = nanmean(low_h_mean_pupil_mat, 1);
%     low_h_pop_sem = nanstd(low_h_mean_pupil_mat, 0, 1) ./ sqrt(sum(~isnan(low_h_mean_pupil_mat), 1));
% 
%     % Plot
%     figure;
%     hold on;
% 
%     upper = pop_avg(1:1301) + pop_sem(1:1301);
%     lower = pop_avg(1:1301) - pop_sem(1:1301);
%     xaxis = [-300:1000];
%     fill([xaxis xaxis(end:-1:1)], [upper lower(end:-1:1)],...
%         [0.5 0.5 0.5], 'EdgeColor', 'none', 'FaceAlpha', 0.3);
%     plot(xaxis, pop_avg(1:1301), 'k', 'LineWidth', 2);
% 
%     upper = high_h_pop_avg(1:1301) + high_h_pop_sem(1:1301);
%     lower = high_h_pop_avg(1:1301) - high_h_pop_sem(1:1301);
%     fill([xaxis xaxis(end:-1:1)], [upper lower(end:-1:1)],...
%         [194 0 77]./255, 'EdgeColor', 'none', 'FaceAlpha', 0.3);
%     plot(xaxis, high_h_pop_avg(1:1301), 'color', [194 0 77]./255, 'LineWidth', 2);
% 
%     upper = low_h_pop_avg(1:1301) + low_h_pop_sem(1:1301);
%     lower = low_h_pop_avg(1:1301) - low_h_pop_sem(1:1301);
%     fill([xaxis xaxis(end:-1:1)], [upper lower(end:-1:1)],...
%         [4 94 167]./255, 'EdgeColor', 'none', 'FaceAlpha', 0.3);
%     plot(xaxis, low_h_pop_avg(1:1301), 'color', [4 94 167]./255, 'LineWidth', 2);
% 
%     % Set axis labels
%     xline(0, '--k');
%     xlim([-300 1000]);
%     xlabel('Time wrt Cue Onset (ms)');
%     ylabel({'Population averaged', 'pupil diameter (z-scored)'});
%     title('All Sessions');
%     hold off;
% 
% end

%% 2) Calulate pupil change
% Now that we have an idea of what we're trying to capture, calculate the
% evoked pupil response as a difference.
num_sessions = length(all_pyr_cleaned_data);
all_evoked_pupil = cell(num_sessions, 1);

for i = 1:num_sessions
    cur_session = all_pyr_cleaned_data{i};
    num_trials = cur_session.header.numTrials;
    evoked_pupil = nan(num_trials, 1);
    window = 1000;
    for tr = 1:num_trials
        sample_on_idx = new_getEventIndex(cur_session, tr, 19);
        if ~isnan(cur_session.bs_evoked_pupil(tr)) % Use same criteria as clean_pupil, will have to change
            evoked_end = sample_on_idx+window;
            peak = max(nanrunmean(cur_session.cleaned_pupil(tr, sample_on_idx:evoked_end), 50));
            trough = min(cur_session.cleaned_pupil(tr, sample_on_idx:evoked_end));
            evoked_pupil(tr) = peak - trough;

            % if will_plot
            %     figure;
            %     xaxis = [-300:1000];
            %     plot(xaxis, cur_session.cleaned_pupil(tr, sample_on_idx-300:evoked_end),...
            %         'k', 'LineWidth', 2);
            %     xline(0, '--k');
            %     yline(trough, '--k');
            %     yline(peak, '--k');
            %     xlim([-300 1000]);
            %     xlabel('Time wrt Cue Onset (ms)');
            %     ylabel('Pupil diameter (z-scored)');
            %     title("Trial "+num2str(tr));
            % end
        end
    end
    all_evoked_pupil{i} = evoked_pupil;
end