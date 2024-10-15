%function plot_pupil_corr(data_w_pupil)
%% Plot correlations between pupil diameter and firing rate

% Create figure
% fig = figure;

%% 1) Evoked baseline-subtracted pupil vs. baseline pupil residuals
% Calculate the Spearman rank correlation between baseline-subtracted
% evoked pupil diameter and residual baseline pupil diameter for each
% session
num_sessions = length(all_pyr_cleaned_data);
all_rhos = nan(num_sessions, 1);
all_pvals = nan(num_sessions, 1);
low_h_rhos = nan(num_sessions, 1);
high_h_rhos = nan(num_sessions, 1);
for i = 1:num_sessions
    % Overall correlation
    cur_sesion = all_pyr_cleaned_data{i};
    mdlBaseline = fitlm(cur_sesion.times.trial_begin, cur_sesion.baseline_pupil);
    residualsBaseline = mdlBaseline.Residuals.Raw;
    bs_evoked = cur_sesion.bs_evoked_pupil;
    [rho, pval] = corr(residualsBaseline, bs_evoked, 'Type', 'Spearman',...
        'Rows', 'complete');
    all_rhos(i) = rho;
    all_pvals(i) = pval;

    %% Correlation by switch rate
    % low_h_residualsBaseline = residualsBaseline(cur_sesion.values.hazard == 0.05);
    % low_h_bs_evoked = bs_evoked(cur_sesion.values.hazard == 0.05);
    % if ~isempty(low_h_residualsBaseline)
    %     [rho, pval] = corr(low_h_residualsBaseline, low_h_bs_evoked,...
    %         'Type', 'Spearman', 'Rows', 'complete');
    %     low_h_rhos(i) = rho;
    % end
    % 
    % high_h_residualsBaseline = residualsBaseline(cur_sesion.values.hazard == 0.50);
    % high_h_bs_evoked = bs_evoked(cur_sesion.values.hazard == 0.50);
    % if ~isempty(high_h_residualsBaseline)
    %     [rho, pval] = corr(high_h_residualsBaseline, high_h_bs_evoked,...
    %         'Type', 'Spearman', ['Ro' ...
    %         'ws'], 'complete');
    %     high_h_rhos(i) = rho;
    % end
end

% Plot the distribution of all coefficients
median_rho = nanmedian(all_rhos);
significant_idx = all_pvals < 0.01;
figure;
hold on;
xaxis = rand(num_sessions, 1);
scatter(xaxis(significant_idx), all_rhos(significant_idx), 50, ...
    'filled', 'MarkerFaceColor', 'r');
scatter(xaxis(~significant_idx), all_rhos(~significant_idx), 50, ...
    'MarkerEdgeColor', 'r');
line([min(xaxis), max(xaxis)], [median_rho, median_rho],...
         'LineWidth', 4, 'Color', 'k');
yline(0, 'k--');
xlim([-0.5, 1.5]);
xticks([]);
xticklabels([]);
ylim([-1, 1]);
ylabel('Spearman Rank Correlation Coefficient');
title('Evoked vs. Baseline Pupil');

% By switch rate
% subplot(1,3,2)
% histogram(low_h_rhos, 'FaceColor', [4 94 167]./255);
% xline(0, 'k--');
% xlim([-1, 1]);
% xlabel('Spearman Rank Correlation Coefficient');
% ylabel('Number of Sessions');
% title('Evoked vs. Baseline Pupil');
% 
% subplot(1,3,3)
% histogram(high_h_rhos, 'FaceColor', [194 0 77]./255);
% xline(0, 'k--');
% xlim([-1, 1]);
% xlabel('Spearman Rank Correlation Coefficient');
% ylabel('Number of Sessions');
% title('Evoked vs. Baseline Pupil');

%% 2) Baseline firing rate residuals vs. baseline pupil residuals
% Initialize variables
all_baseline_fr = cell(num_sessions, 1);
all_evoked_fr = cell(num_sessions, 1);
all_rhos = nan(169, 1); % Total units
all_pvals = nan(169, 1);
all_rhos_partial = nan(169, 1); % Total units
all_pvals_partial = nan(169, 1);

overall_unit = 1;
% For each session
for i = 1:num_sessions
    % Get data and baseline pupil residuals
    cur_session = all_pyr_cleaned_data{i};

    mdl_baseline_pupil = fitlm(cur_session.times.trial_begin, cur_session.baseline_pupil);
    residuals_baseline_pupil = mdl_baseline_pupil.Residuals.Raw;
    
    % Get the index for sample_on for each trial
    num_trials = cur_session.header.numTrials;
    sample_on_idxs = nan(num_trials, 1);
    for tr = 1:num_trials
        sample_on_idxs(tr) = new_getEventIndex(cur_session, tr, 19); % sample_on = column 19
    end
    
    % Initialize variables
    unit_ids = cur_session.spikes.id;
    num_units = length(unit_ids);
    baseline_fr = nan(num_trials, num_units);
    evoked_fr = nan(num_trials, num_units);
    % For each unit
    for u = 1:num_units
        % Get its data
        unit_spikes = squeeze(cur_session.binned_spikes(u,:,:)); % ms x trials

        % For each trial
        for tr = 1:num_trials
            sample_on_idx = sample_on_idxs(tr);
            % For only valid, completed trials
            if sample_on_idx > 500 && ~isnan(sample_on_idx) && ~isnan(cur_session.ids.choice(tr))
                % Baseline = average firing rate 500ms before sample_on
                baseline_fr(tr, u) = mean(unit_spikes((sample_on_idx - 500):(sample_on_idx - 1), tr));
                % For convenience, calculate evoked here to be used later
                % Evoked = average firing rate 300ms after sample_on
                evoked_fr(tr, u) = mean(unit_spikes(sample_on_idx:(sample_on_idx + 300), tr));
            end
        end

        % Compute residuals
        mdl_baseline_fr = fitlm(cur_session.times.trial_begin, baseline_fr(:, u));
        residuals_baseline_fr = mdl_baseline_fr.Residuals.Raw;

        % Get correlation between baseline pupil and baseline firing rate
        % (both are residuals)
        [rho, pval] = corr(residuals_baseline_pupil, residuals_baseline_fr,...
            'Type', 'Spearman', 'Rows', 'complete');
        all_rhos(overall_unit) = rho;
        all_pvals(overall_unit) = pval;

        % Compare full correlation between residuals to partial correlation
        % to un-corrected values
        [rho, pval] = partialcorr(cur_session.baseline_pupil,...
            baseline_fr(:, u), cur_session.times.trial_begin,...
            'Type', 'Spearman', 'Rows', 'complete');
        all_rhos_partial(overall_unit) = rho;
        all_pvals_partial(overall_unit) = pval;

        overall_unit = overall_unit + 1; % Increment
    end

    % Add this session's baseline and evoked firing rates to cell array
    all_baseline_fr{i} = baseline_fr;
    all_evoked_fr{i} = evoked_fr;
end

% Plot
% Full correlation
median_rho = nanmedian(all_rhos);
significant_idx = all_pvals < 0.01;
figure;
hold on;
xaxis = rand(169, 1);
scatter(xaxis(significant_idx), all_rhos(significant_idx), 50, ...
    'filled', 'MarkerFaceColor', 'r');
scatter(xaxis(~significant_idx), all_rhos(~significant_idx), 50, ...
    'MarkerEdgeColor', 'r');
line([min(xaxis), max(xaxis)], [median_rho, median_rho],...
         'LineWidth', 4, 'Color', 'k');
yline(0, 'k--');
xlim([-0.5, 1.5]);
xticks([]);
xticklabels([]);
ylim([-1, 1]);
ylabel('Spearman Rank Correlation Coefficient');
title('Baseline FR Residual vs. Baseline Pupil Residual');

% Partial correlation
median_rho = nanmedian(all_rhos_partial);
significant_idx = all_pvals_partial < 0.01;
figure;
hold on;
xaxis = rand(169, 1);
scatter(xaxis(significant_idx), all_rhos_partial(significant_idx), 50, ...
    'filled', 'MarkerFaceColor', 'r');
scatter(xaxis(~significant_idx), all_rhos_partial(~significant_idx), 50, ...
    'MarkerEdgeColor', 'r');
line([min(xaxis), max(xaxis)], [median_rho, median_rho],...
         'LineWidth', 4, 'Color', 'k');
yline(0, 'k--');
xlim([-0.5, 1.5]);
xticks([]);
xticklabels([]);
ylim([-1, 1]);
ylabel('Spearman Rank Partial Correlation Coefficient');
title('Baseline FR vs. Baseline Pupil');

%% 3) Evoked baseline-subtracted firing rate vs. baseline firing rate residuals
% Subtract baseline from evoked firing rate for each session
all_bs_evoked_fr = cell(num_sessions, 1);
for i = 1:num_sessions
    % Get this session's firing rates and number of units
    cur_baseline = all_baseline_fr{i};
    cur_evoked = all_evoked_fr{i};
    num_units = size(cur_evoked, 2);

    % For each unit
    bs_evoked_fr = nan(size(cur_evoked));
    for u = 1:num_units
        % Subtract its baseline from evoked firing rate
        bs_evoked_fr(:, u) = cur_evoked(:, u) - cur_baseline(:, u);
    end
    % Save
    all_bs_evoked_fr{i} = bs_evoked_fr;
end

% Calculate correlation for each session
all_rhos = nan(169, 1); % Total units
all_pvals = nan(169, 1);

overall_unit = 1;
for i = 1:num_sessions
    bs_evoked_fr = all_bs_evoked_fr{i};
    baseline_fr = all_baseline_fr{i};
    num_units = size(bs_evoked_fr, 2);
    
    for u = 1:num_units
        mdl_baseline_fr = fitlm(all_pyr_cleaned_data{i}.times.trial_begin, baseline_fr(:, u));
        residuals_baseline_fr = mdl_baseline_fr.Residuals.Raw;

        [rho, pval] = corr(residuals_baseline_fr, bs_evoked_fr(:,u),...
            'Type', 'Spearman', 'Rows', 'complete');
        all_rhos(overall_unit) = rho;
        all_pvals(overall_unit) = pval;
    end
end