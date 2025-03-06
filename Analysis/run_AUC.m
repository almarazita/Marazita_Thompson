%% Compute AUC for each neuron (high vs. low hazard rate visual response)

population_ROCs = [];
population_ROC_percentiles = {};

for unit_num = 1:length(unit_data)

    % Get neuron
    data = unit_data(unit_num);

    % Create 2 conditions (hazard rates) x 1 "stimulus" (visual epoch) cell
    % array
    stimulus_responses = cell(2, 1);

    low_tr = data.values.hazard == 0.05;
    low = data.epochs.target_on(low_tr);
    %low = data.epochs.memory(low_tr);

    high_tr = data.values.hazard == 0.50;
    high = data.epochs.target_on(high_tr);
    %high = data.epochs.memory(high_tr);

    stimulus_responses{1} = low;
    stimulus_responses{2} = high;

    % Compute AUC
    % Prefer high hazard (pref = 2)
    % Trial_min = 3
    % num_bootstraps = 0
    [raw_ROC, ROC_percentiles] = GrandChoiceProb_Permutation(stimulus_responses, 2, 3, 1000);
    population_ROCs(unit_num) = raw_ROC; % Add to array
    population_ROC_percentiles{unit_num} = ROC_percentiles;
    unit_data(unit_num).visual_ROC = raw_ROC; % Add to unit_table
    if raw_ROC < ROC_percentiles(1) || raw_ROC > ROC_percentiles(2)
        unit_data(unit_num).visual_ROC_sig = 1;
    else
        unit_data(unit_num).visual_ROC_sig = 0;
    end
    %unit_data(unit_num).memory_ROC = raw_ROC;

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
histogram(population_ROCs, 'BinEdges', bin_edges, 'Normalization', ...
    'count', 'FaceColor', 'w', 'EdgeColor', 'k');
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
ylabel('Neurons', 'FontSize', 14);
title('Visual', 'FontSize', 14);
%title('Memory', 'FontSize', 14);