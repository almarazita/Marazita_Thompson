%% Plot correlations between pupil diameter and firing rate
%% Setup
% Get data
results = get_pupil_spike_vectors(all_pyr_cleaned_data);
num_sessions = length(all_pyr_cleaned_data);

%% Caclulate correlations
baseline_evoked_pupil = nan(num_sessions, 1);
baseline_evoked_pupil_pvals = nan(num_sessions, 1);

baseline_evoked_FR = nan(169, 1); % Total units
baseline_evoked_FR_pvals = nan(169, 1);

baseline_pupil_baseline_FR = nan(169, 1);
baseline_pupil_baseline_FR_pvals = nan(169, 1);

evoked_pupil_evoked_FR = nan(169, 1);
evoked_pupil_evoked_FR_pvals = nan(169, 1);

evoked_FR_baseline_pupil = nan(169, 1);
evoked_FR_baseline_pupil_pvals = nan(169, 1);

baseline_FR_evoked_pupil = nan(169, 1);
baseline_FR_evoked_pupil_pvals = nan(169, 1);

for i = 1:num_sessions
    % 1) Baseline-evoked pupil
    residuals_baseline_pupil = results.all_residual_baseline_pupil{i};
    bs_evoked_pupil = results.all_bs_evoked_pupil{i};
    [rho, pval] = corr(residuals_baseline_pupil, bs_evoked_pupil,...
        'Type', 'Spearman', 'Rows', 'complete');
    baseline_evoked_pupil(i) = rho;
    baseline_evoked_pupil_pvals(i) = pval;

    % For each unit
    unit_ids = cur_session.spikes.id;
    num_units = length(unit_ids);
    for u = 1:num_units
        % 2) Baseline-evoked firing rate
        residuals_baseline_fr = results.all_residual_baseline_fr{i};
        bs_evoked_fr = results.all_bs_evoked_fr;
        [rho, pval] = corr(residuals_baseline_fr(:, u), bs_evoked_fr(:,u),...
            'Type', 'Spearman', 'Rows', 'complete');
        baseline_evoked_FR(overall_unit) = rho;
        baseline_evoked_FR_pvals(overall_unit) = pval;

        % 3) Baseline pupil-baseline firing rate
        [rho, pval] = corr(residuals_baseline_pupil, residuals_baseline_fr(:, u),...
            'Type', 'Spearman', 'Rows', 'complete');
        baseline_pupil_baseline_FR(overall_unit) = rho;
        baseline_pupil_baseline_FR_pvals(overall_unit) = pval;

        % 4) Evoked pupil-evoked firing rate
        [rho, pval] = corr(bs_evoked_pupil, bs_evoked_fr(:,u),...
            'Type', 'Spearman', 'Rows', 'complete');
        evoked_pupil_evoked_FR(overall_unit) = rho;
        evoked_pupil_evoked_FR_pvals(overall_unit) = pval;

        % 5) Baseline pupil-evoked firing rate
        [rho, pval] = corr(residuals_baseline_pupil, bs_evoked_fr(:,u),...
            'Type', 'Spearman', 'Rows', 'complete');
        evoked_FR_baseline_pupil(overall_unit) = rho;
        evoked_FR_baseline_pupil_pvals(overall_unit) = pval;

        % 6) Evoked pupil-baseline firing rate
        [rho, pval] = corr(bs_evoked_pupil, residuals_baseline_fr(:, u),...
            'Type', 'Spearman', 'Rows', 'complete');
        baseline_FR_evoked_pupil(overall_unit) = rho;
        baseline_FR_evoked_pupil_pvals(overall_unit) = pval;

        overall_unit = overall_unit + 1;
    end
end

%% Create figure
fig = figure;
% 1) Baseline-evoked pupil
median_rho = nanmedian(baseline_evoked_pupil);
significant_idx = baseline_evoked_pupil_pvals < 0.01;
subplot(3, 2, 1);
hold on;
xaxis = rand(num_sessions, 1);
scatter(xaxis(significant_idx), baseline_evoked_pupil(significant_idx), 50, ...
    'filled', 'MarkerFaceColor', 'r');
scatter(xaxis(~significant_idx), baseline_evoked_pupil(~significant_idx), 50, ...
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

% 2) Baseline-evoked firing rate
median_rho = nanmedian(baseline_evoked_FR);
significant_idx = baseline_evoked_FR_pvals < 0.01;
subplot(3, 2, 2);
hold on;
xaxis = rand(169, 1);
scatter(xaxis(significant_idx), baseline_evoked_FR(significant_idx), 50, ...
    'filled', 'MarkerFaceColor', 'r');
scatter(xaxis(~significant_idx), baseline_evoked_FR(~significant_idx), 50, ...
    'MarkerEdgeColor', 'r');
line([min(xaxis), max(xaxis)], [median_rho, median_rho],...
         'LineWidth', 4, 'Color', 'k');
yline(0, 'k--');
xlim([-0.5, 1.5]);
xticks([]);
xticklabels([]);
ylim([-1, 1]);
ylabel('Spearman Rank Correlation Coefficient');
title('Evoked FR vs. Baseline FR Residual');

% 3)
median_rho = nanmedian(all_rhos);
significant_idx = all_pvals < 0.01;
subplot(3, 2, 3);
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

% 4) Evoked FR vs. evoked pupil
median_rho = nanmedian(evoked_pupil_evoked_FR);
significant_idx = evoked_pupil_evoked_FR_pvals < 0.01;
subplot(3, 2, 4);
hold on;
xaxis = rand(169, 1);
scatter(xaxis(significant_idx), evoked_pupil_evoked_FR(significant_idx), 50, ...
    'filled', 'MarkerFaceColor', 'r');
scatter(xaxis(~significant_idx), evoked_pupil_evoked_FR(~significant_idx), 50, ...
    'MarkerEdgeColor', 'r');
line([min(xaxis), max(xaxis)], [median_rho, median_rho],...
         'LineWidth', 4, 'Color', 'k');
yline(0, 'k--');
xlim([-0.5, 1.5]);
xticks([]);
xticklabels([]);
ylim([-1, 1]);
ylabel('Spearman Rank Correlation Coefficient');
title('Evoked FR vs. Evoked Pupil');

% 5) Evoked FR vs. baseline pupil
median_rho = nanmedian(evoked_FR_baseline_pupil);
significant_idx = evoked_FR_baseline_pupil_pvals < 0.01;
subplot(3, 2, 5);
hold on;
xaxis = rand(169, 1);
scatter(xaxis(significant_idx), evoked_FR_baseline_pupil(significant_idx), 50, ...
    'filled', 'MarkerFaceColor', 'r');
scatter(xaxis(~significant_idx), evoked_FR_baseline_pupil(~significant_idx), 50, ...
    'MarkerEdgeColor', 'r');
line([min(xaxis), max(xaxis)], [median_rho, median_rho],...
         'LineWidth', 4, 'Color', 'k');
yline(0, 'k--');
xlim([-0.5, 1.5]);
xticks([]);
xticklabels([]);
ylim([-1, 1]);
ylabel('Spearman Rank Correlation Coefficient');
title('Evoked FR vs. Baseline Pupil Residual');

% 6) Baseline FR vs. evoked pupil
median_rho = nanmedian(baseline_FR_evoked_pupil);
significant_idx = baseline_FR_evoked_pupil_pvals < 0.01;
subplot(3, 2, 6);
hold on;
xaxis = rand(169, 1);
scatter(xaxis(significant_idx), baseline_FR_evoked_pupil(significant_idx), 50, ...
    'filled', 'MarkerFaceColor', 'r');
scatter(xaxis(~significant_idx), baseline_FR_evoked_pupil(~significant_idx), 50, ...
    'MarkerEdgeColor', 'r');
line([min(xaxis), max(xaxis)], [median_rho, median_rho],...
         'LineWidth', 4, 'Color', 'k');
yline(0, 'k--');
xlim([-0.5, 1.5]);
xticks([]);
xticklabels([]);
ylim([-1, 1]);
ylabel('Spearman Rank Correlation Coefficient');
title('Baseline FR Residual vs. Evoked Pupil');

%% Scatterplots for each session
for i = 1:num_sessions
    cur_session = all_pyr_cleaned_data{i};
    num_units = length(cur_session.spikes.id);
    
    for u = 1:num_units
        figure;
    
        % 1. Evoked vs. baseline pupil
        subplot(3, 2, 1);
        hold on;
        xaxis = all_baseline_pupil{i};
        yaxis = cur_session.bs_evoked_pupil;
        scatter(xaxis, yaxis, 25, 'blue',...
        'filled', 'MarkerEdgeColor', 'w', 'LineWidth', 0.5);
        yline(0, 'k--', 'LineWidth', 1.5);
        xlabel('Baseline Pupil');
        ylabel('Evoked Pupil');
        title('Evoked vs. Baseline Pupil');
    
        % 2. Evoked vs. baseline FR
        subplot(3, 2, 2);
        hold on;
        xaxis = all_baseline_fr{i};
        xaxis = xaxis(:,u);
        yaxis = all_evoked_fr{i};
        yaxis = yaxis(:,u);
        scatter(xaxis, yaxis, 25, 'red',...
        'filled', 'MarkerEdgeColor', 'w', 'LineWidth', 0.5);
        yline(0, 'k--', 'LineWidth', 1.5);
        xlabel('Baseline FR');
        ylabel('Evoked FR');
        title('Evoked vs. Baseline FR');
    
        % 3. Baseline pupil vs. baseline FR
        subplot(3, 2, 3);
        hold on;
        xaxis = all_baseline_fr{i};
        xaxis = xaxis(:,u);
        yaxis = all_baseline_pupil{i};
        scatter(xaxis, yaxis, 25, 'k',...
        'filled', 'MarkerEdgeColor', 'w', 'LineWidth', 0.5);
        yline(0, 'k--', 'LineWidth', 1.5);
        xlabel('Baseline FR');
        ylabel('Baseline Pupil');
        title('Baseline Pupil vs. Baseline FR');
    
        % 4. Evoked pupil vs. evoked FR
        subplot(3, 2, 4);
        hold on;
        xaxis = all_evoked_fr{i};
        xaxis = xaxis(:,u);
        yaxis = cur_session.bs_evoked_pupil;
        scatter(xaxis, yaxis, 25, 'k',...
        'filled', 'MarkerEdgeColor', 'w', 'LineWidth', 0.5);
        yline(0, 'k--', 'LineWidth', 1.5);
        xlabel('Evoked FR');
        ylabel('Evoked Pupil');
        title('Evoked Pupil vs. Evoked FR');
    
        % 5. Evoked FR vs. baseline pupil
        subplot(3, 2, 5);
        hold on;
        xaxis = all_baseline_pupil{i};
        yaxis = all_evoked_fr{i};
        yaxis = yaxis(:,u);
        scatter(xaxis, yaxis, 25, 'k',...
        'filled', 'MarkerEdgeColor', 'w', 'LineWidth', 0.5);
        yline(0, 'k--', 'LineWidth', 1.5);
        xlabel('Baseline Pupil');
        ylabel('Evoked FR');
        title('Evoked FR vs. Baseline Pupil');
    
        % 6. Evoked pupil vs. baseline FR
        subplot(3, 2, 6);
        hold on;
        xaxis = all_baseline_fr{i};
        xaxis = xaxis(:,u);
        yaxis = cur_session.bs_evoked_pupil;
        scatter(xaxis, yaxis, 25, 'k',...
        'filled', 'MarkerEdgeColor', 'w', 'LineWidth', 0.5);
        yline(0, 'k--', 'LineWidth', 1.5);
        xlabel('Baseline FR');
        ylabel('Evoked Pupil');
        title('Evoked Pupil vs. Baseline FR');

        % Overall title
        filename = cur_session.header.filename;
        startIdx = strfind(filename, 'MM');
        endIdx = strfind(filename, '.hdf5') - 1;
        sessionName = filename(startIdx:endIdx);
        sgtitle([sessionName, "Unit "+num2str(cur_session.spikes.id(u))],...
            'interpreter', 'none');
    
    end
end