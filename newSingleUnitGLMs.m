function unit_table = newSingleUnitGLMs(data,unit_table,unit_num)
%%
%% Check for visual response in the main conditions
criteria = ~isnan(data.values.hazard);
lm_table = table();
lm_table.FR = data.epochs.baseline(criteria)' + data.epochs.target_on(criteria)'; % Add back baseline
lm_table.Base = data.epochs.baseline(criteria)'; % Baseline
lm_table(isnan(data.ids.sample_id(criteria)),:) = []; % remove trials where target id didn't exist
unit_table.visual_evoked_p(unit_num) = ranksum(lm_table.FR,lm_table.Base); % grouping rather than continuous is probably more appropriate

%% Check for memory related activity compared to baseline
criteria = ~isnan(data.values.hazard);
lm_table = table();
lm_table.FR = data.epochs.baseline(criteria)' + data.epochs.memory(criteria)'; % Add back baseline
lm_table.Base = data.epochs.baseline(criteria)'; % Baseline
lm_table(isnan(data.ids.sample_id(criteria)),:) = []; % remove trials where target id didn't exist
unit_table.memory_evoked_p(unit_num) = ranksum(lm_table.FR,lm_table.Base); % grouping rather than continuous is probably more appropriate

%% Check for saccade related activity compared to baseline
criteria = ~isnan(data.values.hazard);
lm_table = table();
lm_table.FR = data.epochs.baseline(criteria)' + data.epochs.saccade_on(criteria)'; % Add back baseline
lm_table.Base = data.epochs.baseline(criteria)'; % Baseline
lm_table(isnan(data.ids.sample_id(criteria)),:) = []; % remove trials where target id didn't exist
unit_table.saccade_evoked_p(unit_num) = ranksum(lm_table.FR,lm_table.Base); % grouping rather than continuous is probably more appropriate

%% Check for hazard-dependent visual evoked activity
criteria = ~isnan(data.values.hazard);
lm_table = table();
lm_table.FR = data.epochs.target_on(criteria)'; % Visual
lm_table.Hazard = data.values.hazard(criteria); % hazard
lm_table(isnan(data.ids.sample_id(criteria)),:) = []; % remove trials where target id didn't exist
unit_table.hazard_visual_evoked_p(unit_num) = anova1(lm_table.FR,lm_table.Hazard,'off'); % grouping rather than continuous is probably more appropriate

%% Check for target (cue onset) tuning
criteria = ~isnan(data.values.hazard);
lm_table = table();
lm_table.FR = data.epochs.target_on(criteria)'; % Extract baseline subtracted FR for each trial
lm_table.targets = data.ids.sample_id(criteria); % Extract all target IDs
lm_table(isnan(data.ids.sample_id(criteria)),:) = []; % remove trials where target id didn't exist
lm_table.coded_targets = sign(lm_table.targets); % alternative - above is positive, below is negative categorization
lm = fitlm(lm_table,'FR~targets'); % Target tuning
unit_table.cue_visual_p(unit_num) = anova1(lm_table.FR,lm_table.targets,'off'); % grouping rather than continuous is probably more appropriate

%% How about a larger, but simpler model?
criteria = ~isnan(data.values.hazard);
lm_table = table();
lm_table.FR = data.epochs.target_on(criteria)'; % Extract baseline subtracted FR for each trial
lm_table.targets = data.ids.sample_id(criteria); % Extract all target IDs
lm_table.hazard = data.values.hazard(criteria);
lm_table.time = data.times.trial_begin(criteria) - mean(data.times.trial_begin(criteria));
lm_table(isnan(data.values.hazard(criteria)) | isnan(data.ids.sample_id(criteria)),:) = []; % remove trials where target id didn't exist
lm_table.coded_targets = sign(lm_table.targets); % alternative - above is positive, below is negative categorization
lm = fitlm(lm_table,'FR~time + targets + hazard'); % Target tuning
p_vals = lm.Coefficients.pValue;
unit_table.simple_model_target(unit_num) = p_vals(2);
unit_table.simple_model_hazard(unit_num) = p_vals(3);
unit_table.simple_model_time(unit_num) = p_vals(4);
if length(unique(lm_table.hazard))~=2 % only 1 hazard, or somehow tested more than 2..
    % unit_table.hazard_cue_time_p(unit_num) = NaN; % interaction term (caution interpreting main effects)
    % unit_table.hazard_cue_cue_p(unit_num) = NaN; % main effect of cue
    % unit_table.hazard_cue_hazard_p(unit_num) = NaN; % main effect of hazard
else
    % [p, atab] = anovan(lm_table.FR, {lm_table.targets lm_table.hazard}, ...
    %     'model',2, 'sstype',2, ...
    %     'varnames',strvcat('Target', 'Hazard'),...
    %     'display','off');
    % unit_table.hazard_cue_int_p(unit_num) = p(3); % interaction term (caution interpreting main effects)
    % unit_table.hazard_cue_cue_p(unit_num) = p(1); % main effect of cue
    % unit_table.hazard_cue_hazard_p(unit_num) = p(2); % main effect of hazard
end


%% Check for hazard-dependent target (cue onset) tuning
criteria = ~isnan(data.values.hazard);
lm_table = table();
lm_table.FR = data.epochs.target_on(criteria)'; % Extract baseline subtracted FR for each trial
lm_table.targets = data.ids.sample_id(criteria); % Extract all target IDs
lm_table.hazard = data.values.hazard(criteria);
lm_table(isnan(data.values.hazard(criteria)) | isnan(data.ids.sample_id(criteria)),:) = []; % remove trials where target id didn't exist
lm_table.coded_targets = sign(lm_table.targets); % alternative - above is positive, below is negative categorization
lm = fitlm(lm_table,'FR~targets*hazard'); % Target tuning
if length(unique(lm_table.hazard))~=2 % only 1 hazard, or somehow tested more than 2..
    unit_table.hazard_cue_int_p(unit_num) = NaN; % interaction term (caution interpreting main effects)
    unit_table.hazard_cue_cue_p(unit_num) = NaN; % main effect of cue
    unit_table.hazard_cue_hazard_p(unit_num) = NaN; % main effect of hazard
else
    [p, atab] = anovan(lm_table.FR, {lm_table.targets lm_table.hazard}, ...
        'model',2, 'sstype',2, ...
        'varnames',strvcat('Target', 'Hazard'),...
        'display','off');
    unit_table.hazard_cue_int_p(unit_num) = p(3); % interaction term (caution interpreting main effects)
    unit_table.hazard_cue_cue_p(unit_num) = p(1); % main effect of cue
    unit_table.hazard_cue_hazard_p(unit_num) = p(2); % main effect of hazard
end

%% Check for hazard-dependent target (cue onset) tuning without interaction
criteria = ~isnan(data.values.hazard);
lm_table = table();
lm_table.FR = data.epochs.target_on(criteria)'; % Extract baseline subtracted FR for each trial
lm_table.targets = data.ids.sample_id(criteria)./8; % Extract all target IDs,normalize to +-0.5
lm_table.hazard = data.values.hazard(criteria)>0.25;
lm_table.hazard = lm_table.hazard - 0.5;
lm_table(isnan(data.values.hazard(criteria)) | isnan(data.ids.sample_id(criteria)),:) = []; % remove trials where target id didn't exist
lm = fitlm(lm_table,'FR~targets + hazard'); % Target tuning
if length(unique(lm_table.hazard))~=2 % only 1 hazard, or somehow tested more than 2..
    unit_table.lm_hazard_cue_cue_b(unit_num) = NaN; % main effect of cue
    unit_table.lm_hazard_cue_hazard_b(unit_num) = NaN; % main effect of hazard
else
    unit_table.lm_hazard_cue_cue_b(unit_num) = lm.Coefficients.Estimate(2); % main effect of cue
    unit_table.lm_hazard_cue_hazard_b(unit_num) = lm.Coefficients.Estimate(3); % main effect of hazard
end

%% Check for target (memory) tuning
criteria = ~isnan(data.times.target_off);
lm_table = table();
lm_table.FR = data.epochs.memory(criteria)';
lm_table.targets = data.ids.sample_id(criteria);
criteria = ~isnan(data.values.hazard(criteria)) & ~isnan(data.ids.sample_id(criteria));
lm_table(~criteria,:) = [];
lm = fitlm(lm_table,'FR~targets');
unit_table.cue_memory(unit_num) = anova1(lm_table.FR,lm_table.targets,'off'); % grouping rather than continuous is probably more appropriate

%% Check for hazard dependent target (memory) tuning
criteria = ~isnan(data.times.target_off);
lm_table = table();
lm_table.FR = data.epochs.memory(criteria)';
lm_table.targets = data.ids.sample_id(criteria);
lm_table.hazard = data.values.hazard(criteria);
lm_table(isnan(data.ids.sample_id(criteria)) | isnan(data.values.hazard(criteria)),:) = [];
lm = fitlm(lm_table,'FR~hazard*targets');
if length(unique(lm_table.hazard))~=2 % only 1 hazard, or somehow tested more than 2..
    unit_table.memory_hazard_cue_int_p(unit_num) = NaN; % interaction term (caution interpreting main effects)
    unit_table.memory_hazard_cue_cue_p(unit_num) = NaN; % main effect of cue
    unit_table.memory_hazard_cue_hazard_p(unit_num) = NaN; % main effect of hazard
else
    [p, atab] = anovan(lm_table.FR, {lm_table.targets lm_table.hazard}, ...
        'model',2, 'sstype',2, ...
        'varnames',strvcat('Target', 'Hazard'),...
        'display','off');
    unit_table.memory_hazard_cue_int_p(unit_num) = p(3); % interaction term (caution interpreting main effects)
    unit_table.memory_hazard_cue_cue_p(unit_num) = p(1); % main effect of cue
    unit_table.memory_hazard_cue_hazard_p(unit_num) = p(2); % main effect of hazard
end
%% Check for saccade (choice target) tuning
lm_table = table();
lm_table.FR = data.epochs.saccade_on';
lm_table.choice = data.ids.choice;
lm_table(isnan(data.ids.choice) | data.ids.choice == 0 ,:) = []; % sometimes there are choices that equal 0, not sure what that means/how it happens.
lm = fitlm(lm_table,'FR~choice');
unit_table.saccade_choice(unit_num) = anova1(lm_table.FR,lm_table.choice,'off'); % grouping rather than continuous is probably more appropriate
%% Check for hazard dependent saccade (choice target) tuning
lm_table = table();
lm_table.FR = data.epochs.saccade_on';
lm_table.choice = data.ids.choice;
lm_table.hazard = data.values.hazard;
lm_table(isnan(data.ids.choice) | data.ids.choice == 0 | isnan(data.values.hazard) ,:) = []; % sometimes there are choices that equal 0, not sure what that means/how it happens.
lm = fitlm(lm_table,'FR~hazard*choice');
if length(unique(lm_table.hazard))~=2 % only 1 hazard, or somehow tested more than 2..
    unit_table.hazard_saccade_choice_int_p(unit_num) = NaN; % interaction term (caution interpreting main effects)
    unit_table.hazard_saccade_choice_p(unit_num) = NaN; % main effect of target
    unit_table.hazard_saccade_choice_hazard_p(unit_num) = NaN; % main effect of hazard
else
    unit_table.lm_int_hazard_saccade_choice(unit_num,:) = {lm.Coefficients.pValue};
    [p, atab] = anovan(lm_table.FR, {lm_table.choice lm_table.hazard}, ...
        'model',2, 'sstype',2, ...
        'varnames',strvcat('Choice', 'Hazard'),...
        'display','off');
    unit_table.hazard_saccade_choice_int_p(unit_num) = p(3); % interaction term (caution interpreting main effects)
    unit_table.hazard_saccade_choice_p(unit_num) = p(1); % main effect of target
    unit_table.hazard_saccade_choice_hazard_p(unit_num) = p(2); % main effect of hazard
end
%% Saccade target location?
lm_table = table();
event_idx = data.ids.task_id == 1;
lm_table.FR = data.epochs.saccade_on(event_idx)';
lm_table.target = atan2d(data.values.t1_x(event_idx), data.values.t1_y(event_idx));
lm_table.cos_target = cosd(lm_table.target);
lm_table.sin_target = sind(lm_table.target);
if ~isempty(lm_table)
    lm = fitlm(lm_table,'FR~cos_target + sin_target');
    unit_table.ODR_saccade_target(unit_num) = anova1(lm_table.FR,lm_table.target,'off'); % grouping rather than continuous is probably more appropriate
else
    unit_table.ODR_saccade_target(unit_num) = NaN; % No ODR saccade trials
end

%% Switching related activity
% if sum(data.values.hazard == 0.05)>3 % need at least 3 trials
%     lm_table = table();
%     lm_table.FR = data.epochs.target_on';
%     lm_table.hazard = data.values.hazard;
%     lm_table.switch = data.values.choice_switch - 0.5; % centers the variable
%     lm_table(data.values.hazard ~= 0.05,:) = []; % only look at switching activity for low hazard
%     lm = fitlm(lm_table,'FR~switch');
%     unit_table.switch_p(unit_num) = anova1(lm_table.FR,lm_table.switch,'off'); % grouping rather than continuous is probably more appropriate
% else
%     unit_table.switch_p(unit_num) = NaN;
% end

%% Visual: Calculate a discrimination index for the different hazards

criteria = data.values.hazard == 0.05 & ~isnan(data.ids.sample_id) & data.ids.score==1;

trial_targets = data.ids.sample_id(criteria); % Extract all target IDs
targets = unique(trial_targets);
trial_FR = data.epochs.target_on(criteria)'; % Extract baseline subtracted FR for each trial
max_trials = max(histcounts(trial_targets));
DI_mat = nan(max_trials,length(targets));
for ith_targ = 1:length(targets)
    curr_targ = targets(ith_targ);
    targ_FR = trial_FR(trial_targets==curr_targ);
    n_t = length(targ_FR);
    if n_t>max_trials
        error('requires matrrix expansion, trials exceeded expectations');
    end
    DI_mat(1:n_t,ith_targ) = targ_FR;
end
if sum(data.values.hazard == 0.05)>3 % need at least 3 trials
    unit_table.LowH_DI(unit_num) = DiscriminationIndex(DI_mat);
else
    unit_table.LowH_DI(unit_num) = NaN;
end
if size(DI_mat,2)>8
    unit_table.lowH_targ_mean(unit_num,:) = nanmean(DI_mat,1);
    unit_table.lowH_targ_mod(unit_num) = (nanmax(unit_table.lowH_targ_mean(unit_num,:)) - nanmin(unit_table.lowH_targ_mean(unit_num,:)))/(nanmax(unit_table.lowH_targ_mean(unit_num,:)) + nanmin(unit_table.lowH_targ_mean(unit_num,:)));
    unit_table.lowH_targ_unsigned_mean(unit_num,:) = [nanmean([DI_mat(:,1); DI_mat(:,end)]),...
        nanmean([DI_mat(:,2); DI_mat(:,end-1)]),...
        nanmean([DI_mat(:,3); DI_mat(:,end-2)]),...
        nanmean([DI_mat(:,4); DI_mat(:,end-3)])...
        nanmean(DI_mat(:,5))];
else
    unit_table.lowH_targ_mean(unit_num,:) = nan(1,9);
    unit_table.lowH_targ_mod(unit_num) = NaN;
    unit_table.lowH_targ_unsigned_mean(unit_num,:) = nan(1,5);
end

criteria = data.values.hazard == 0.5 & ~isnan(data.ids.sample_id) & data.ids.score==1;

trial_targets = data.ids.sample_id(criteria); % Extract all target IDs
targets = unique(trial_targets);
trial_FR = data.epochs.target_on(criteria)'; % Extract baseline subtracted FR for each trial
max_trials = max(histcounts(trial_targets));
DI_mat = nan(max_trials,length(targets));
for ith_targ = 1:length(targets)
    curr_targ = targets(ith_targ);
    targ_FR = trial_FR(trial_targets==curr_targ);
    n_t = length(targ_FR);
    if n_t>max_trials
        error('requires matrrix expansion, trials exceeded expectations');
    end
    DI_mat(1:n_t,ith_targ) = targ_FR;
end
if sum(data.values.hazard == 0.5)>3 % need at least 3 trials
    unit_table.HighH_DI(unit_num) = DiscriminationIndex(DI_mat);
else
    unit_table.HighH_DI(unit_num) = NaN;
end
if size(DI_mat,2)>8
    unit_table.highH_targ_mean(unit_num,:) = nanmean(DI_mat,1);
    unit_table.highH_targ_mod(unit_num) = (nanmax(unit_table.highH_targ_mean(unit_num,:)) - nanmin(unit_table.highH_targ_mean(unit_num,:)))/(nanmax(unit_table.highH_targ_mean(unit_num,:)) + nanmin(unit_table.highH_targ_mean(unit_num,:)));
    unit_table.highH_targ_unsigned_mean(unit_num,:) = [nanmean([DI_mat(:,1); DI_mat(:,end)]),...
        nanmean([DI_mat(:,2); DI_mat(:,end-1)]),...
        nanmean([DI_mat(:,3); DI_mat(:,end-2)]),...
        nanmean([DI_mat(:,4); DI_mat(:,end-3)])...
        nanmean(DI_mat(:,5))];
else
    unit_table.highH_targ_mean(unit_num,:) = nan(1,9);
    unit_table.highH_targ_mod(unit_num) = NaN;
    unit_table.highH_targ_unsigned_mean(unit_num,:) = nan(1,5);
end



%% Memory: Calculate a discrimination index for the different hazards
if sum(data.values.hazard == 0.05)>3 % need at least 3 trials

    criteria = data.values.hazard == 0.05 & ~isnan(data.ids.sample_id) & data.ids.score==1;

    trial_targets = data.ids.sample_id(criteria); % Extract all target IDs
    targets = unique(trial_targets);
    trial_FR = data.epochs.memory(criteria)'; % Extract baseline subtracted FR for each trial
    max_trials = max(histcounts(trial_targets));
    DI_mat = nan(max_trials,length(targets));
    for ith_targ = 1:length(targets)
        curr_targ = targets(ith_targ);
        targ_FR = trial_FR(trial_targets==curr_targ);
        n_t = length(targ_FR);
        if n_t>max_trials
            error('requires matrrix expansion, trials exceeded expectations');
        end
        DI_mat(1:n_t,ith_targ) = targ_FR;
    end
    unit_table.Memory_LowH_DI(unit_num) = DiscriminationIndex(DI_mat);
    if size(DI_mat,2)>8
        unit_table.Memory_lowH_targ_mean(unit_num,:) = nanmean(DI_mat,1);
    else
        unit_table.Memory_lowH_targ_mean(unit_num,:) = nan(1,9);
    end
else
    unit_table.Memory_lowH_targ_mean(unit_num,:) = nan(1,9);
    unit_table.Memory_LowH_DI(unit_num) = NaN;
end
if sum(data.values.hazard == 0.5)>3 % need at least 3 trials

    criteria = data.values.hazard == 0.5 & ~isnan(data.ids.sample_id) & data.ids.score==1;

    trial_targets = data.ids.sample_id(criteria); % Extract all target IDs
    targets = unique(trial_targets);
    trial_FR = data.epochs.memory(criteria)'; % Extract baseline subtracted FR for each trial
    max_trials = max(histcounts(trial_targets));
    DI_mat = nan(max_trials,length(targets));
    for ith_targ = 1:length(targets)
        curr_targ = targets(ith_targ);
        targ_FR = trial_FR(trial_targets==curr_targ);
        n_t = length(targ_FR);
        if n_t>max_trials
            error('requires matrrix expansion, trials exceeded expectations');
        end
        DI_mat(1:n_t,ith_targ) = targ_FR;
    end
    unit_table.Memory_HighH_DI(unit_num) = DiscriminationIndex(DI_mat);
    if size(DI_mat,2)>8
        unit_table.Memory_highH_targ_mean(unit_num,:) = nanmean(DI_mat,1);
    else
        unit_table.Memory_highH_targ_mean(unit_num,:) = nan(1,9);
    end
else
    unit_table.Memory_highH_targ_mean(unit_num,:) = nan(1,9);
    unit_table.Memory_HighH_DI(unit_num) = NaN;
end

%% Calculate saccade selectivity using an ROC analysis in the two different hazard conidtions
% Use only the center (ambiguous) stimuli
% min_trials = 3;
% n_perms = 5;
% criteria = data.values.hazard == 0.05 & data.ids.sample_id == 0;
% if sum(criteria)>3 % need at least 3 trials
%     upper_targ = {data.epochs.saccade_on(criteria & data.ids.choice == 1)}; % Extract baseline subtracted FR for each trial
%     lower_targ = {data.epochs.saccade_on(criteria & data.ids.choice == 2)}; % Extract baseline subtracted FR for each trial
%     roc_data = [upper_targ, lower_targ]';
%     [unit_table.LowH_ROC(unit_num), unit_table.LowH_ROC_Chance(unit_num,:)] = GrandChoiceProb_Permutation(roc_data,2,min_trials,n_perms);
% else
%     unit_table.LowH_ROC(unit_num) = NaN;
%     unit_table.LowH_ROC_Chance(unit_num,:) = [NaN NaN];
% end
%
% criteria = data.values.hazard == 0.5 & data.ids.sample_id == 0;
% if sum(criteria)>3 % need at least 3 trials
%     upper_targ = {data.epochs.saccade_on(criteria & data.ids.choice == 1)}; % Extract baseline subtracted FR for each trial
%     lower_targ = {data.epochs.saccade_on(criteria & data.ids.choice == 2)}; % Extract baseline subtracted FR for each trial
%     roc_data = [upper_targ, lower_targ]';
%     [unit_table.HighH_ROC(unit_num), unit_table.HighH_ROC_Chance(unit_num,:)] = GrandChoiceProb_Permutation(roc_data,2,min_trials,n_perms);
% else
%     unit_table.HighH_ROC(unit_num) = NaN;
%     unit_table.HighH_ROC_Chance(unit_num,:) = [NaN NaN];
% end



end