function unit_table = glm_full_model(unit_data, unit_table)
%% Run the full model using pre-defiend epochs

for unit_idx = 1:length(unit_data)

    %% 1. Set-up.
    % Choose the unit
    data = unit_data(unit_idx);
    cue_loc = data.ids.sample_id;
    target_off = data.times.target_off;
    % AODR with weak evidence only
    %valid_trials = ismember(cue_loc,[-1, 1]) & ~isnan(target_off);
    valid_trials = ~isnan(target_off);
        
    % Define the indicies that create each epoch
    visual_epoch = [301, 600];
    visual_epoch = repmat(visual_epoch, sum(valid_trials), 1);

    cue_off = round(target_off(valid_trials)*1000);
    memory_starts = cue_off + 400 + 1;
    memory_ends = memory_starts + 400;
    memory_epoch = [memory_starts, memory_ends]; % valid_trials x 2
    
    sac_on_idx = round(data.times.sac_on(valid_trials)*1000);
    sac_starts = sac_on_idx - 300 + 1;
    saccade_epoch = [sac_starts, sac_on_idx]; % valid_trials x 2, a few may overlap with memory epoch

    epochs = cat(3, visual_epoch, memory_epoch, saccade_epoch);
    
    coeffs = cell(3, 1); % Will store coefficients from each epochs's model
    
    %% 2. Create a table for the unit to run the model.
    % a) Cue location: -0.5 (stay) or 0.5 (switch)
    prevH = [nan; data.values.hazard(1:end-1)];
    thisH = data.values.hazard;
    prevState = [nan; data.ids.correct_target(1:end-1)];

    switch_cue = false(length(cue_loc), 1);
    % Coded by weak evidence only
    % switch_cue(thisH==prevH & prevState==1 & ismember(cue_loc,[1]))=1; % Bottom to top
    % switch_cue(thisH==prevH & prevState==2 & ismember(cue_loc,[-1]))=1; % Top to bottom
    switch_cue(thisH==prevH & prevState==1 & cue_loc > 0) = true; % Bottom to top
    switch_cue(thisH==prevH & prevState==2 & cue_loc < 0) = true; % Top to bottom
    cue_loc(switch_cue) = 0.5; % Distal
    cue_loc(~switch_cue) = -0.5; % Proximal
    cue_loc(thisH ~= prevH) = nan; % Excluded
    cue_loc = cue_loc(valid_trials);
    
    % b) Hazard rate: -0.5 or 0.5
    hazard = data.values.hazard(valid_trials);
    hazard(hazard==0.05) = -0.5; % Center the variable

    % c) Choice: -0.5 (stay) or 0.5 (switch)
    choice = data.ids.choice;
    is_switch = (thisH==prevH) & (prevState ~= choice); % same block and chose target opposite previously correct one
    choice(is_switch) = 0.5; % recode
    choice(~is_switch) = -0.5;
    % Coding by absolute location
    % choice(choice==1) = -0.5;
    % choice(choice==2) = 0.5;
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
    
    for epoch_num = 1:3
    
        % iii) Isolate evoked window of interest
        windows = epochs(:, :, epoch_num);
        window_starts = windows(:, 1);
        window_ends = windows(:, 2);

        fr = nan(sum(valid_trials), 1);
    
        % Compute per trial
        for tr = 1:sum(valid_trials)

            window_start = window_starts(tr);
            window_end = window_ends(tr);
            if (window_end > size(baseline_subtracted, 1))
                fprintf("Unit %d has valid trial %d with epoch %d outside length of data\n", unit_idx, tr, epoch_num);
                continue % skips over, leaving nan firing rate
            end
            baseline_subtracted_window = baseline_subtracted(window_start:window_end, tr); % window_size x 1 trial
            mean_baseline_subtracted = mean(baseline_subtracted_window, "omitnan"); % scalar
            
            z_scored = (mean_baseline_subtracted - mu) ./ sigma; % scalar
            fr(tr) = z_scored;

        end
        
        % iv) Combine predictor and response variables into design matrix
        % Full model
        %X = table(cue_loc, hazard, choice, fr, 'VariableNames', {'cue_loc', 'hazard', 'choice', 'fr'});
        % Reduced model
        X = table(cue_loc, hazard, fr, 'VariableNames', {'cue_loc', 'hazard', 'fr'});
        
        %% 3. Run the model, saving results.
        %mdl = fitlm(X, 'fr ~ cue_loc*hazard*choice');
        mdl = fitlm(X, 'fr ~ cue_loc*hazard');
        coeffs{epoch_num} = mdl.Coefficients;
    
    end

    % Save to unit_table
    unit_table.coeffs{unit_idx} = coeffs;

end