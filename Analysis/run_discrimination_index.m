%% Calculate a discrimination index for the different hazards
visual = false;

for unit_num = 1:95

    data = unit_data(unit_num);
    
    % Low H
    if sum(data.values.hazard == 0.05) > 3 % need at least 3 trials
        
        criteria = data.values.hazard == 0.05 & ~isnan(data.ids.sample_id);
        
        trial_targets = data.ids.sample_id(criteria); % Extract all target IDs
        targets = unique(trial_targets);
        if visual
            trial_FR = data.epochs.target_on(criteria)'; % Extract baseline subtracted FR for each trial
        else
            trial_FR = data.epochs.memory(criteria)';
        end
        max_trials = max(histcounts(trial_targets));
        DI_mat = nan(max_trials, length(targets));
    
        for ith_targ = 1:length(targets)
    
            curr_targ = targets(ith_targ);
            targ_FR = trial_FR(trial_targets == curr_targ);
            n_t = length(targ_FR);
            if n_t > max_trials
                error('requires matrix expansion, trials exceeded expectations');
            end
            DI_mat(1:n_t, ith_targ) = targ_FR; % trials x 1 of visual epoch FR in low H for current target location
    
        end
    
        unit_data(unit_num).LowH_DI = discrimination_index(DI_mat);
    else
        unit_data(unit_num).LowH_DI = NaN;
    end
    
    % High H
    if sum(data.values.hazard == 0.5) > 3 % need at least 3 trials
        
        criteria = data.values.hazard == 0.5 & ~isnan(data.ids.sample_id);
        
        trial_targets = data.ids.sample_id(criteria); % Extract all target IDs
        targets = unique(trial_targets);
        if visual
            trial_FR = data.epochs.target_on(criteria)'; % Extract baseline subtracted FR for each trial
        else
            trial_FR = data.epochs.memory(criteria)';
        end
        max_trials = max(histcounts(trial_targets));
        DI_mat = nan(max_trials, length(targets));
        for ith_targ = 1:length(targets)
    
            curr_targ = targets(ith_targ);
            targ_FR = trial_FR(trial_targets == curr_targ);
            n_t = length(targ_FR);
            if n_t > max_trials
                error('requires matrix expansion, trials exceeded expectations');
            end
            DI_mat(1:n_t, ith_targ) = targ_FR;
    
        end
    
        unit_data(unit_num).HighH_DI = discrimination_index(DI_mat);
    else
        unit_data(unit_num).HighH_DI = NaN;
    end

    % Check for visual response in the main conditions
    % criteria = ~isnan(data.values.hazard);
    % lm_table = table();
    % lm_table.FR = data.epochs.baseline(criteria)' + data.epochs.target_on(criteria)'; % Add back baseline
    % lm_table.Base = data.epochs.baseline(criteria)'; % Baseline
    % lm_table(isnan(data.ids.sample_id(criteria)), :) = []; % remove trials where target id didn't exist
    % unit_data(unit_num).visual_evoked_p = anova1(lm_table.FR, lm_table.Base, 'off'); % grouping rather than continuous is probably more appropriate

end