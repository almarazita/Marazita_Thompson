%% Compute AUC for each neuron (high vs. low hazard rate visual response)

population_ROCs = [];
%population_ROC_percentiles = {};

for unit_num = 1:length(unit_data)

    % Get neuron
    data = unit_data(unit_num);

    % Create 2 conditions (hazard rates) x 1 "stimulus" (visual epoch) cell
    % array
    stimulus_responses = cell(2, 1);

    low_tr = data.values.hazard == 0.05;
    %low = data.epochs.target_on(low_tr); % visual
    low = data.epochs.memory(low_tr); % memory

    high_tr = data.values.hazard == 0.50;
    %high = data.epochs.target_on(high_tr); % visual
    high = data.epochs.memory(high_tr); % memory

    stimulus_responses{1} = low;
    stimulus_responses{2} = high;

    % Compute AUC
    % Prefer high hazard (pref = 2)
    % Trial_min = 3
    % num_bootstraps = 1000
    [raw_ROC, ROC_percentiles] = GrandChoiceProb_Permutation(stimulus_responses, 2, 3, 0);
    population_ROCs(unit_num) = raw_ROC; % Add to array
    %population_ROC_percentiles{unit_num} = ROC_percentiles;
    %unit_data(unit_num).visual_ROC = raw_ROC; % Add to unit_table. visual
    unit_data(unit_num).memory_ROC = raw_ROC; % memory
    %if raw_ROC < ROC_percentiles(1) || raw_ROC > ROC_percentiles(2)
        %unit_data(unit_num).visual_ROC_sig = 1; % visual
        %unit_data(unit_num).memory_ROC_sig = 1; % memory
    %else
        %unit_data(unit_num).visual_ROC_sig = 0; % visual
        %unit_data(unit_num).memory_ROC_sig = 0; % memory
    %end

end

%% Run stats
med = median(population_ROCs);
fprintf('Median: %.4f\n', med);
centered_population = population_ROCs - 0.5;
p = signtest(centered_population);
fprintf('p-value from Sign Test: %.4f\n', p);
p = signrank(centered_population);
fprintf('p-value from Sign Rank: %.4f\n', p);
[~, p] = ttest(centered_population);
fprintf('p-value from T Test: %.4f\n', p);

%% Plot histogram of raw ROCs
num_bins = 25;
bin_width = 1 / num_bins;  
bin_edges = 0:bin_width:1;

% Create the histogram
figure;
hold on;
%is_responsive = [unit_data.visual_evoked_p].' < 0.05;
%is_red = [unit_data.visual_ROC].' > 0.5; % visual
%is_blue = [unit_data.visual_ROC].' < 0.5; % visual
is_red = [unit_data.memory_ROC].' > 0.5; % memory
is_blue = [unit_data.memory_ROC].' < 0.5; % memory
histogram(population_ROCs, 'BinEdges', bin_edges, ...
    'Normalization', 'count', 'FaceColor', 'w', 'EdgeColor', 'k', ...
    'FaceAlpha', 0.8, 'LineWidth', 1);
%is_sig = logical([unit_data.visual_ROC_sig].'); % visual
is_sig = logical([unit_data.memory_ROC_sig].'); % memory
histogram(population_ROCs(is_sig & is_blue), 'BinEdges', bin_edges, ...
    'FaceColor', "#0860A9", 'EdgeColor', 'k', 'FaceAlpha', 0.8, ...
    'LineWidth', 1);
histogram(population_ROCs(is_sig & is_red), 'BinEdges', bin_edges, ...
    'FaceColor', "#C21F51", 'EdgeColor', 'k', 'FaceAlpha', 0.8, ...
    'LineWidth', 1);
plot([med, med], y_limits, 'k:', 'LineWidth', 1.5);
y_limits = ylim;
arrow_size = 0.03 * diff(y_limits);
arrow_x = med;
arrow_y = y_limits(2) + 0.05*diff(y_limits);
x_triangle = [-0.01 0 0.01] + arrow_x;
y_triangle = [0.5 -0.5 0.5] + arrow_y;
fill(x_triangle, y_triangle, 'k', 'EdgeColor', 'k', 'FaceColor', 'k');
xlim([0, 1]);
xlabel('AUC', 'FontSize', 14);
ylabel('Number of Neurons', 'FontSize', 14);
%title('Visual', 'FontSize', 14); % visual
title('Memory', 'FontSize', 14); % memory
ax = gca;
ax.LineWidth = 2;
set(ax, 'FontSize', 14);
axis square;