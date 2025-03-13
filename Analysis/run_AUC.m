%% Compute AUC for each neuron (high vs. low hazard rate visual response)

population_ROCs = [];
%population_ROC_percentiles = {};
num_units = length(unit_data);

for unit_num = 1:num_units

    % Get neuron
    data = unit_data(unit_num);
    fprintf('Computing AUC for unit %d/%d\n', unit_num, num_units);

    % Compute baseline-subtracted baseline
    baseline = data.epochs.baseline;
    % spikes = squeeze(unit_data(unit_num).binned_spikes(:,1:300,:));
    % baseline_subtracted = spikes - baseline;
    % bs_baseline = mean(baseline_subtracted);

    % Create 2 conditions (hazard rates) x 1 "stimulus" (visual epoch) cell
    % array
    stimulus_responses = cell(2, 1);

    low_tr = data.values.hazard == 0.05;
    low = baseline(low_tr); % raw baseline
    %low = bs_baseline(low_tr); % baseline
    %low = data.epochs.target_on(low_tr); % visual
    %low = data.epochs.memory(low_tr); % memory

    high_tr = data.values.hazard == 0.50;
    high = baseline(high_tr); % raw baseline
    %high = bs_baseline(high_tr); % baseline
    %high = data.epochs.target_on(high_tr); % visual
    %high = data.epochs.memory(high_tr); % memory

    stimulus_responses{1} = low;
    stimulus_responses{2} = high;

    % Compute AUC
    % Prefer high hazard (pref = 2)
    % Trial_min = 3
    % num_bootstraps = 1000
    [raw_ROC, ROC_percentiles] = GrandChoiceProb_Permutation(stimulus_responses, 2, 3, 1000);
    population_ROCs(unit_num) = raw_ROC; % Add to array
    population_ROC_percentiles{unit_num} = ROC_percentiles;

    % Add raw value and significance to unit_table
    unit_data(unit_num).raw_baseline_ROC = raw_ROC; % baseline
    %unit_data(unit_num).baseline_ROC = raw_ROC; % baseline
    %unit_data(unit_num).visual_ROC = raw_ROC; % visual
    %unit_data(unit_num).memory_ROC = raw_ROC; % memory

    if raw_ROC < ROC_percentiles(1) || raw_ROC > ROC_percentiles(2)
        unit_data(unit_num).raw_baseline_ROC_sig = 1; % raw baseline
        %unit_data(unit_num).baseline_ROC_sig = 1; % baseline
        %unit_data(unit_num).visual_ROC_sig = 1; % visual
        %unit_data(unit_num).memory_ROC_sig = 1; % memory
    else
        unit_data(unit_num).raw_baseline_ROC_sig = 0; % raw baseline
        %unit_data(unit_num).baseline_ROC_sig = 0; % baseline
        %unit_data(unit_num).visual_ROC_sig = 0; % visual
        %unit_data(unit_num).memory_ROC_sig = 0; % memory
    end

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