%% Plot population median over time (window)
% Assumes you just ran run_AUC_sliding_window to get the table of
% statistics, and variables are already in workspace.

% Setup
step_size = 10;
window_width = 150;

window_starts = -300:step_size:900-window_width; % whole time course
window_ends = window_starts + window_width - 1;
window_starts = window_starts * -1;

window_centers = (window_starts*-1 + window_ends) / 2;
means = slide_stats_table_150ms.Mean;
SEMs = slide_stats_table_150ms.SEM;

% Mean +/- SEM
figure;
hold on;

yline(0.5, 'k--', 'LineWidth', 1);
shadedErrorBar(window_centers, means, SEMs);
plot([-300, 0], [0.45, 0.45], 'b', 'LineWidth', 3);
plot([100, 249], [0.45, 0.45], 'Color', '#1A9E77', 'LineWidth', 3);
plot([300, 899], [0.45, 0.45], 'Color', '#D76227', 'LineWidth', 3);

xlim([-300, 899]);
ylim([0.44, 0.56]);

xlabel('Time from cue onset (ms)');
ylabel('AUC');