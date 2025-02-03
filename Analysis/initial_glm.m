function unit_table = initial_glm(unit_data, unit_table)
%% Create simple models to examine what neurons are tuned for

for unit_idx = 1:length(unit_data)

    %% 1. Set-up.
    % Choose the unit
    data = unit_data(unit_idx);
    valid_trials = ~isnan(data.ids.sample_id); % AODR only
        
    % Choose 300ms sliding window times
    window_size = 300;
    step_size = 10;
    sac_on_idx = data.times.sac_on(valid_trials)*1000;
    earliest_sac_on = round(min(sac_on_idx));
    max_start = earliest_sac_on - window_size;
    window_starts = 301:step_size:max_start;
    window_ends = window_starts + window_size - 1;
    num_windows = length(window_starts);
    coeffs = cell(num_windows, 1); % Will store coefficients from each window's model
    
    %% 2. Create a table for the unit to run the model.
    % a) Cue location: -4, -3, -2, -1, 0, 1, 2, 3, or 4
    cue_loc = data.ids.sample_id;
    cue_loc = cue_loc(valid_trials);
    
    % b) Hazard rate: 0.5 or -0.5
    hazard = data.values.hazard(valid_trials);
    hazard(hazard==0.05) = -0.5; % Center the variable
    
    % c) Firing rate: baseline-subtract, z-scored firing rate over a given
    % evoked window after cue onset
    % i) Subtract the baseline firing rate
    evoked = squeeze(data.binned_spikes); % ms x all trials
    evoked = evoked(:, valid_trials); % ms x valid trials
    baseline = data.epochs.baseline(valid_trials);
    baseline_subtracted = evoked - baseline;
    
    for window_num = 1:num_windows
    
        % ii) Isolate evoked window of interest
        window_start = window_starts(window_num);
        window_end = window_ends(window_num);
    
        baseline_subtracted_window = baseline_subtracted(window_start:window_end, :);
        mean_baseline_subtracted = mean(baseline_subtracted_window, 1, "omitnan"); % 1 x trials
    
        % iii) Z-score (keep interpretation consistent)
        mu = mean(mean_baseline_subtracted, "omitnan"); % average over all trials
        sigma = std(mean_baseline_subtracted, "omitnan"); % std over all trials
        z_scored = (mean_baseline_subtracted - mu) ./ sigma; % 1 x trials
        fr = z_scored';
        
        % iv) Combine predictor and response variables into design matrix
        X = table(cue_loc, hazard, fr, 'VariableNames', {'cue_loc', 'hazard', 'fr'});
        
        %% 3. Run the model, saving results.
        mdl = fitlm(X, 'fr ~ cue_loc*hazard');
        coeffs{window_num} = mdl.Coefficients;
    
    end

    % Save to unit_table
    unit_table.coeffs{unit_idx} = coeffs;

end