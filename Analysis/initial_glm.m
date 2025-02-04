function unit_table = initial_glm(unit_data, unit_table)
%% Create simple models to examine what neurons are tuned for

for unit_idx = 1:length(unit_data)

    %% 1. Set-up.
    % Choose the unit
    data = unit_data(unit_idx);
    cue_loc = data.ids.sample_id;
    valid_trials = ismember(cue_loc,[-1, 0, 1]); % AODR with weak evidence only
        
    % Choose 300ms sliding window times
    window_size = 150;
    step_size = 10;
    sac_on_idx = data.times.sac_on(valid_trials)*1000;
    earliest_sac_on = round(min(sac_on_idx));
    max_start = earliest_sac_on - window_size;
    window_starts = 301:step_size:max_start;
    window_ends = window_starts + window_size - 1;
    num_windows = length(window_starts);
    coeffs = cell(num_windows, 1); % Will store coefficients from each window's model
    
    %% 2. Create a table for the unit to run the model.
    % a) Cue location: -1, 0, or 1
    cue_loc = cue_loc(valid_trials);
    
    % b) Hazard rate: 0.5 or -0.5
    hazard = data.values.hazard(valid_trials);
    hazard(hazard==0.05) = -0.5; % Center the variable

    % c) Choice: -0.5 (stay) or 0.5 (switch)
    % Information needed to determine whether a choice was switch
    prevH = [nan; data.values.hazard(1:end-1)];
    thisH = data.values.hazard;
    prevState = [nan; data.ids.correct_target(1:end-1)];
    choice = data.ids.choice;
    is_switch = (thisH==prevH) & (prevState ~= choice); % same block and chose target opposite previously correct one
    choice(is_switch) = 0.5; % recode
    choice(~is_switch) = -0.5;
    choice = choice(valid_trials);

    % d) Firing rate: baseline-subtract, z-scored firing rate over a given
    % evoked window after cue onset
    % i) Subtract the baseline firing rate
    evoked = squeeze(data.binned_spikes); % ms x all trials
    evoked = evoked(:, valid_trials); % ms x valid trials
    baseline = data.epochs.baseline(valid_trials);
    baseline_subtracted = evoked - baseline;

    % ii) Z-score (keep interpretation consistent)
    mu = mean(baseline_subtracted, "all", "omitnan"); % scalar, using the full trial duration
    sigma = nanstd(baseline_subtracted, 0, 'all'); % scalar
    
    for window_num = 1:num_windows
    
        % iii) Isolate evoked window of interest
        window_start = window_starts(window_num);
        window_end = window_ends(window_num);
    
        baseline_subtracted_window = baseline_subtracted(window_start:window_end, :); % window_size x valid_trials
        mean_baseline_subtracted = mean(baseline_subtracted_window, 1, "omitnan"); % 1 x valid_trials
        
        z_scored = (mean_baseline_subtracted - mu) ./ sigma; % 1 x valid_trials
        fr = z_scored';
        
        % iv) Combine predictor and response variables into design matrix
        X = table(cue_loc, hazard, choice, fr, 'VariableNames', {'cue_loc', 'hazard', 'choice', 'fr'});
        
        %% 3. Run the model, saving results.
        mdl = fitlm(X, 'fr ~ cue_loc + hazard + choice + cue_loc*hazard + cue_loc*hazard*choice');
        coeffs{window_num} = mdl.Coefficients;
    
    end

    % Save to unit_table
    unit_table.coeffs{unit_idx} = coeffs;

end