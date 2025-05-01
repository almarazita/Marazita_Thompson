%% Plot bar graph of median raw ROCs
% To be run after run_AUC for each period for each comparison (high-low
% switch rate or stay-switch)

% By ChatGPT

% Extract ROC values into vectors
baseline = [unit_data.baseline_ROC];
switch_baseline = [unit_data.switch_baseline_ROC];

visual = [unit_data.visual_ROC];
switch_visual = [unit_data.switch_visual_ROC];

memory = [unit_data.memory_ROC];
switch_memory = [unit_data.switch_memory_ROC];

% Compute means, ignoring NaNs
means = [
    nanmean(baseline), nanmean(switch_baseline);
    nanmean(visual), nanmean(switch_visual)
    nanmean(memory), nanmean(switch_memory)
];

% Compute SEMs (standard error of the mean)
sems = [
    nanstd(baseline) / sqrt(sum(~isnan(baseline))), ...
    nanstd(switch_baseline) / sqrt(sum(~isnan(switch_baseline)));
    
    nanstd(visual) / sqrt(sum(~isnan(visual))), ...
    nanstd(switch_visual) / sqrt(sum(~isnan(switch_visual)))
    
    nanstd(memory) / sqrt(sum(~isnan(memory))), ...
    nanstd(switch_memory) / sqrt(sum(~isnan(switch_memory)))
];

% Bar plot
figure;
hold on;
bar_handle = bar(means, 'grouped');
% Colors
bar_handle(1).FaceColor = "#006991";  % Certain
bar_handle(2).FaceColor = "#EC008C";  % Conflicting

% Add error bars
num_groups = size(means, 1);
num_bars = size(means, 2);
group_width = min(0.8, num_bars/(num_bars + 1.5));
for i = 1:num_bars
    x = (1:num_groups) - group_width/2 + (2*i-1) * group_width / (2*num_bars);
    errorbar(x, means(:, i), sems(:, i), 'k', 'linestyle', 'none', 'linewidth', 1.2);
end

% Labels and formatting
yline(0.5, 'k--', 'LineWidth', 1, 'HandleVisibility', 'off');
ylim([0 1]);
xticks(1:3);

ax = gca;
ax.LineWidth = 2;
ax.XColor = 'k';
ax.YColor = 'k';
set(ax, 'FontSize', 14);
axis square;

xticklabels({'Baseline', 'Visual Period', 'Memory Period'});
ylabel('Mean AUC');
legend({'Certain evidence', 'Conflicting evidence'}, 'Location', 'NorthWest');

%% Perform one-sample two-tailed t-tests against 0.5
[~, p_baseline] = ttest(baseline, 0.5);
[~, p_switch_baseline] = ttest(switch_baseline, 0.5);

[~, p_visual] = ttest(visual, 0.5);
[~, p_switch_visual] = ttest(switch_visual, 0.5);

[~, p_memory] = ttest(memory, 0.5);
[~, p_switch_memory] = ttest(switch_memory, 0.5);

% Display results
fprintf('Baseline:          p = %.4f\n', p_baseline);
fprintf('Switch Baseline:   p = %.4f\n', p_switch_baseline);
fprintf('Visual:            p = %.4f\n', p_visual);
fprintf('Switch Visual:     p = %.4f\n', p_switch_visual);
fprintf('Memory:            p = %.4f\n', p_memory);
fprintf('Switch Memory:     p = %.4f\n', p_switch_memory);