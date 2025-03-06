%% Calculate visual discrimination index
function DI = DiscriminationIndex(data)
%% DI = DiscriminationIndex(data) calculates a discrimination index given
% the matrix, data, which is an NxM matrix:
% N = trials
% M = conditions.
% Use NaN values to pad the matrix if there are unequal trials.
% See: Prince SJD, Pointon AD, Cumming BG, Parker AJ. 2002. 
% Quantitative analysis of the responses of V1 neurons to horizontal 
% disparity in dynamic random-dot stereograms. 
% Journal of Neurophysiology 87:191–208. DOI: https://doi.org/10.1152/jn.00465.2000

% Written by LWT 10/31/23

mean_data = nanmean(data, 1); % mean over trials
R_max = max(mean_data);
R_min = min(mean_data);
M = size(data,2);
N = sum(~isnan(data(:)));
errors = data - mean_data;
SSE = sum(errors(:).^2, 'omitnan');

DI = (R_max - R_min)/...
    ((R_max - R_min) + 2*sqrt(SSE/(N-M)));

end

%% Visual: Calculate a discrimination index for the different hazards
for unit_num = 1:95

    data = unit_data(unit_num);
    
    % Low H
    if sum(data.values.hazard == 0.05) > 3 % need at least 3 trials
        
        criteria = data.values.hazard == 0.05 & ~isnan(data.ids.sample_id);
        
        trial_targets = data.ids.sample_id(criteria); % Extract all target IDs
        targets = unique(trial_targets);
        trial_FR = data.epochs.target_on(criteria)'; % Extract baseline subtracted FR for each trial
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
    
        unit_data(unit_num).LowH_DI = DiscriminationIndex(DI_mat);
    else
        unit_data(unit_num).LowH_DI = NaN;
    end
    
    % High H
    if sum(data.values.hazard == 0.5) > 3 % need at least 3 trials
        
        criteria = data.values.hazard == 0.5 & ~isnan(data.ids.sample_id);
        
        trial_targets = data.ids.sample_id(criteria); % Extract all target IDs
        targets = unique(trial_targets);
        trial_FR = data.epochs.target_on(criteria)'; % Extract baseline subtracted FR for each trial
        max_trials = max(histcounts(trial_targets));
        DI_mat = nan(max_trials, length(targets));
        for ith_targ = 1:length(targets)
    
            curr_targ = targets(ith_targ);
            targ_FR = trial_FR(trial_targets == curr_targ);
            n_t = length(targ_FR);
            if n_t > max_trials
                error('requires matrrix expansion, trials exceeded expectations');
            end
            DI_mat(1:n_t, ith_targ) = targ_FR;
    
        end
    
        unit_data(unit_num).HighH_DI = DiscriminationIndex(DI_mat);
    else
        unit_data(unit_num).HighH_DI = NaN;
    end

    %% Attempt at amplitude comparison
    

    % Check for visual response in the main conditions
    criteria = ~isnan(data.values.hazard);
    lm_table = table();
    lm_table.FR = data.epochs.baseline(criteria)' + data.epochs.target_on(criteria)'; % Add back baseline
    lm_table.Base = data.epochs.baseline(criteria)'; % Baseline
    lm_table(isnan(data.ids.sample_id(criteria)), :) = []; % remove trials where target id didn't exist
    unit_data(unit_num).visual_evoked_p = anova1(lm_table.FR, lm_table.Base, 'off'); % grouping rather than continuous is probably more appropriate

end

%% Plot_Low_v_High_DI
visual_evoked_p = [unit_data.visual_evoked_p];
LowH_DI = [unit_data.LowH_DI];
HighH_DI = [unit_data.HighH_DI];
criteria = (visual_evoked_p < 0.05) & ~isnan(LowH_DI) & ~isnan(HighH_DI);

% Plot Visual
figure; hold on;
ax = gca;
ax.LineWidth = 2;
set(ax, 'FontSize', 14);

plot(LowH_DI(criteria), HighH_DI(criteria), 'ok',...
    'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'w', 'MarkerSize', 10);
m = round(max([LowH_DI(criteria); HighH_DI(criteria)]), 1);
xlim([0, 0.6]);
ylim([0, 0.6]);
yticks(xticks());
plot([0, 0.6],[0, 0.6], '--k', 'LineWidth', 2);
box on; axis square;
xlabel('Low Hazard Cue DI');
ylabel('High Hazard Cue DI');
title('Visual Epoch');

% Annotations
n_upper = sum(LowH_DI(criteria) < HighH_DI(criteria));
n_lower = sum(LowH_DI(criteria) > HighH_DI(criteria));

dim = [.3 .5 .3 .3];
annotation('textbox', dim, 'String', ['N = ' num2str(n_upper)], 'FitBoxToText', 'on');
dim = [.7 0 .3 .3];
annotation('textbox', dim, 'String', ['N = ' num2str(n_lower)], 'FitBoxToText', 'on');