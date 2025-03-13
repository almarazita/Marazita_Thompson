%% Plot histogram of raw ROCs
% To be run after run_AUC

num_bins = 25;
bin_width = 1 / num_bins;  
bin_edges = 0:bin_width:1;

is_red = [unit_data.raw_baseline_ROC].' > 0.5; % raw baseline
is_blue = [unit_data.raw_baseline_ROC].' < 0.5; % raw baseline
%is_red = [unit_data.baseline_ROC].' > 0.5; % baseline
%is_blue = [unit_data.baseline_ROC].' < 0.5; % baseline
%is_red = [unit_data.visual_ROC].' > 0.5; % visual
%is_blue = [unit_data.visual_ROC].' < 0.5; % visual
%is_red = [unit_data.memory_ROC].' > 0.5; % memory
%is_blue = [unit_data.memory_ROC].' < 0.5; % memory

is_sig = logical([unit_data.raw_baseline_ROC_sig].'); % raw baseline
%is_sig = logical([unit_data.baseline_ROC_sig].'); % baseline
%is_sig = logical([unit_data.visual_ROC_sig].'); % visual
%is_sig = logical([unit_data.memory_ROC_sig].'); % memory

figure;
hold on;

histogram(population_ROCs, 'BinEdges', bin_edges, ...
    'Normalization', 'count', 'FaceColor', 'w', 'EdgeColor', 'k', ...
    'FaceAlpha', 0.8, 'LineWidth', 1.2);
histogram(population_ROCs(is_sig & is_blue), 'BinEdges', bin_edges, ...
    'FaceColor', "#0860A9", 'EdgeColor', 'k', 'FaceAlpha', 0.8, ...
    'LineWidth', 1.2);
histogram(population_ROCs(is_sig & is_red), 'BinEdges', bin_edges, ...
    'FaceColor', "#C21F51", 'EdgeColor', 'k', 'FaceAlpha', 0.8, ...
    'LineWidth', 1.2);

y_limits = ylim;
plot([med, med], y_limits, 'k:', 'LineWidth', 1.5);
arrow_x = med;
arrow_y = y_limits(2) + 0.05*diff(y_limits) - 0.5;
x_triangle = [-0.0125 0 0.0125] + arrow_x;
y_triangle = [0.025*diff(y_limits) 0 0.025*diff(y_limits)] + arrow_y;
fill(x_triangle, y_triangle, 'k', 'EdgeColor', 'k', 'FaceColor', 'k');

xlim([0, 1]);
xticks(0:0.1:1);
xtickangle(0);
ax = gca;
ax.LineWidth = 2;
ax.XColor = 'k';
ax.YColor = 'k';
set(ax, 'FontSize', 14);
axis square;

xlabel('AUC', 'FontSize', 14);
ylabel('Number of Neurons', 'FontSize', 14);
title('Raw Baseline', 'FontSize', 14); % raw baseline
%title('Baseline', 'FontSize', 14); % baseline
%title('Visual', 'FontSize', 14); % visual
%title('Memory', 'FontSize', 14); % memory