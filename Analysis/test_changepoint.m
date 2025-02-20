%% Statistical test for block transition point using baseline pupil

% Store null distributions for all sessions
num_sessions = 94;
all_H0 = cell(num_sessions, 1);
figure;

for session_num = 1:num_sessions
    % Get data and find trials where the task ID changes
    data = all_pyr_cleaned_data{session_num};
    task_ids = data.ids.task_id;
    change_points = find([false, task_ids(1:end-1)' ~= task_ids(2:end)']);
    % Only care about transitions between low and high switch
    change_points = change_points(task_ids(change_points) ~= 1);
    change_points = change_points(task_ids(change_points-1) ~= 1);
    change_points = change_points(change_points < length(data.baseline_pupil));
    
    % Use baseline pupil values except at indices around change points
    bin_width = 10;
    change_point_bins = [];
    for c = change_points
        half = bin_width/2;
        bin = (c - half):(c + half - 1);
        change_point_bins = [change_point_bins, bin];
    end
    baseline_pupil = data.baseline_pupil(~ismember(1:length(data.baseline_pupil), change_point_bins));
    
    % Construct the null distribution by calculating the difference between the
    % average of the second half of trials and the average of the first half of
    % trials in non-overlaping bins
    num_bins = floor(length(baseline_pupil) / bin_width);
    smoothed_idxs = [];
    smoothed_values = [];
    H0 = [];
    for i = 0:num_bins-1
        start_idx = i * bin_width + 1;
        end_idx = start_idx + bin_width - 1;
        window = baseline_pupil(start_idx:end_idx);
        after = mean(window(half+1:bin_width));
        before = mean(window(1:half));
        diff = after - before;
        
        H0 = [H0, diff];
        smoothed_values = [smoothed_values, before, after];
        smoothed_idxs = [smoothed_idxs, start_idx, end_idx];
    end
    
    % Compute the change in baseline pupil diameter at true change points
    actual_changes = [];
    for c = change_points
        transition_bin = data.baseline_pupil(c-half:c+half-1);
        actual_change = mean(transition_bin(half+1:bin_width) - mean(transition_bin(1:half)));
        actual_changes = [actual_changes, actual_change];
    end

    all_H0{session_num} = H0;
    
    %% Plot
    % % 1) Baseline pupil vs. time
    % figure;
    % subplot(3, 1, 1);
    % co = {[4 94 167]./255, [194 0 77]./255}; % Blue = low, red = high
    % num_trials = data.header.validTrials;
    % colors = zeros(num_trials, 3);
    % for tr = 1:num_trials
    %     if data.values.hazard(tr) == 0.05
    %         colors(tr, :) = co{1};
    %     elseif data.values.hazard(tr) == 0.50
    %         colors(tr, :) = co{2};
    %     else
    %         colors(tr, :) = [0, 0, 0];
    %     end
    % end
    % scatter(data.times.trial_begin, data.baseline_pupil, ...
    %     30, colors, 'filled');
    % xline(data.times.trial_begin(change_points), 'Color', 'yellow', 'LineWidth', 2);
    % yline(0, 'k--', 'LineWidth', 1.5);
    % xlabel('Trial Start Time (ms)');
    % ylabel('Baseline Pupil Diameter');
    % title('Baseline Pupil');
    % 
    % % 2) Test results
    % subplot(3, 1, 2);
    % plot(smoothed_idxs, smoothed_values, 'k');
    % xlabel('Trial Index');
    % ylabel('Average Baseline Pupil Diameter');
    % title('Smoothed Baseline Pupil (no change points)');
    
    % % 3) Null distribution
    % subplot(3, 1, 3);
    LF = prctile(H0, 2.5);
    UF = prctile(H0, 97.5);
    % boxplot(H0, 'Whisker', 'Orientation', 'horizontal', 'Symbol', '');
    % h=findobj('LineStyle','--'); set(h, 'LineStyle','-');
    line([LF LF], [session_num-0.25 session_num+0.25], 'Color', 'k');
    line([UF UF], [session_num-0.25 session_num+0.25], 'Color', 'k');
    hold on;
    change_point_colors = zeros(length(change_points), 3);
    for i = 1:length(change_points)
        if task_ids(change_points(i)) == 2 % h = 0.05
            change_point_colors(i, :) = co{1};
        else % h = 0.50
            change_point_colors(i, :) = co{2};
        end
    end
    scatter(actual_changes, ones(size(actual_changes))*session_num,...
        25, change_point_colors, 'filled');
    % xlim([min([H0, actual_changes]) - 0.5, max([H0, actual_changes]) + 0.5]);
    % xlabel('Pupil Difference');
    % title('Pupil Difference Distribution');
    % set(gca, 'yticklabels', []);
end

max_frames = max(cellfun(@length, all_H0));
H0_mat = nan(max_frames, num_sessions);
for i = 1:num_sessions
    cur_response = all_H0{i};
    H0_mat(1:length(cur_response), i) = cur_response;
end

% 3) Null distribution
b = boxplot(H0_mat, 'plotstyle', 'compact', 'Orientation', 'horizontal', 'Symbol', '');
boxHandles = findobj(b, '-property', 'Color');  % Find all elements with 'Color' property
% Set the color of the components to black
set(boxHandles, 'Color', 'k');
patchHandles = findobj(b, 'Type', 'patch');
set(patchHandles, 'FaceColor', 'k');
outlierHandles = findobj(b, 'Tag', 'Outliers');
set(outlierHandles, 'MarkerEdgeColor', 'k');
whiskerHandles = findobj(b, 'Tag', 'Whisker');
set(whiskerHandles, 'Color', 'k');
medianCircleHandles = findobj(b, 'Tag', 'MedianMarker');
set(medianCircleHandles, 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k');
%h=findobj('LineStyle','--'); set(h, 'LineStyle','-');
%xlim([min([H0, actual_changes]) - 0.5, max([H0, actual_changes]) + 0.5]);
set(gca, 'yticklabels', []);
set(gca, 'y')
xlabel('Pupil Difference');
title('Pupil Difference Distribution');