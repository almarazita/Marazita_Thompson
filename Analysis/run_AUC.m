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
    spikes = squeeze(unit_data(unit_num).binned_spikes(:,1:300,:));
    baseline_subtracted = spikes - baseline;
    bs_baseline = mean(baseline_subtracted);

    % Create 2 conditions (hazard rates) x 1 "stimulus" (epoch) cell
    % array
    %stimulus_responses = cell(2, 1);
    stimulus_responses = cell(2, 2);

    % What the previous correct target and hazard rate were
    prevState = [nan; data.ids.correct_target(1:end-1)];
    thisState = data.ids.correct_target;
    prevH = [nan; data.values.hazard(1:end-1)];
    thisH = data.values.hazard;
    cue_loc = data.ids.sample_id;
    switch_cue = zeros(length(cue_loc),1);
    stay_cue = zeros(length(cue_loc),1);
    
    % The cue signals switch if its position is away from what was previously
    % correct, and we're in the same AODR block
    switch_cue(thisH==prevH & prevState==1 & ismember(cue_loc,[2,3,4]))=1; % Bottom to top
    switch_cue(thisH==prevH & prevState==2 & ismember(cue_loc,[-2,-3,-4]))=1; % Top to bottom
    stay_cue(thisH==prevH & prevState==1 & ismember(cue_loc,[-2,-3,-4]))=1; % Bottom before, bottom now
    stay_cue(thisH==prevH & prevState==2 & ismember(cue_loc,[2,3,4]))=1; % Top before, top now

    % Response
    correct = data.ids.score==1 & ~isnan(data.ids.choice);

    % Switch rate
    %low_tr = data.values.hazard == 0.05;
    low_h = data.values.hazard == 0.05;
    
    % Choose trials
    bottom_stay = low_h & stay_cue & thisState==1 & correct;
    top_stay = low_h & stay_cue & thisState==2 & correct;
    bottom_switch = low_h & switch_cue & thisState==1 & correct;
    top_switch = low_h & switch_cue & thisState==2 & correct;

    %low = baseline(low_tr); % raw baseline
    %low = bs_baseline(low_tr); % baseline
    %low = data.epochs.target_on(low_tr); % visual
    %low = data.epochs.memory(low_tr); % memory

    %high_tr = data.values.hazard == 0.50;
    %high = baseline(high_tr); % raw baseline
    %high = bs_baseline(high_tr); % baseline
    %high = data.epochs.target_on(high_tr); % visual
    %high = data.epochs.memory(high_tr); % memory

    % For stay-switch
    stimulus_responses{1,1} = bs_baseline(bottom_stay);
    stimulus_responses{1,2} = bs_baseline(top_stay);
    stimulus_responses{2,1} = bs_baseline(bottom_switch);
    stimulus_responses{2,2} = bs_baseline(top_switch);

    %stimulus_responses{1} = low;
    %stimulus_responses{2} = high;

    % Compute AUC
    % Prefer high hazard (pref = 2)
    % Trial_min = 3
    % num_bootstraps = 1000
    [raw_ROC, ROC_percentiles] = GrandChoiceProb_Permutation(stimulus_responses, 2, 3, 0);
    population_ROCs(unit_num) = raw_ROC; % Add to array
    %population_ROC_percentiles{unit_num} = ROC_percentiles;

    % Add raw value and significance to unit_table
    %unit_data(unit_num).raw_baseline_ROC = raw_ROC; % baseline
    %unit_data(unit_num).baseline_ROC = raw_ROC; % baseline
    %unit_data(unit_num).visual_ROC = raw_ROC; % visual
    %unit_data(unit_num).memory_ROC = raw_ROC; % memory
    unit_data(unit_num).switch_baseline_ROC = raw_ROC; % switch baseline
    %unit_data(unit_num).switch_visual_ROC = raw_ROC; % switch visual
    %unit_data(unit_num).switch_memory_ROC = raw_ROC; % switch memory

    %if raw_ROC < ROC_percentiles(1) || raw_ROC > ROC_percentiles(2)
        %unit_data(unit_num).raw_baseline_ROC_sig = 1; % raw baseline
        %unit_data(unit_num).baseline_ROC_sig = 1; % baseline
        %unit_data(unit_num).visual_ROC_sig = 1; % visual
        %unit_data(unit_num).memory_ROC_sig = 1; % memory
    %else
        %unit_data(unit_num).raw_baseline_ROC_sig = 0; % raw baseline
        %unit_data(unit_num).baseline_ROC_sig = 0; % baseline
        %unit_data(unit_num).visual_ROC_sig = 0; % visual
        %unit_data(unit_num).memory_ROC_sig = 0; % memory
    %end

end

%% Run stats
med = median(population_ROCs, "omitnan");
fprintf('Median: %.4f\n', med);
centered_population = population_ROCs - 0.5;
p = signtest(centered_population);
fprintf('p-value from Sign Test: %.4f\n', p);
p = signrank(centered_population);
fprintf('p-value from Sign Rank: %.4f\n', p);
[~, p] = ttest(centered_population);
fprintf('p-value from T Test: %.4f\n', p);