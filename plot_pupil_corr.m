%% Plot correlations between pupil diameter and firing rate
%% Setup
% Get data
results = get_pupil_spike_vectors(all_pyr_cleaned_data);
num_sessions = length(all_pyr_cleaned_data);
overall_unit = 1;

baseline_evoked_pupil = nan(94, 1);
baseline_evoked_pupil_pvals = nan(94, 1);
baseline_evoked_FR = nan(169, 1);
baseline_evoked_FR_pvals = nan(169, 1);
baseline_pupil_baseline_FR = nan(169, 1);
baseline_pupil_baseline_FR_pvals = nan(169, 1);
evoked_pupil_evoked_FR = nan(169, 1);
evoked_pupil_evoked_FR_pvals = nan(169, 1);
evoked_FR_baseline_pupil = nan(169, 1);
evoked_FR_baseline_pupil_pvals = nan(169, 1);
baseline_FR_evoked_pupil = nan(169, 1);
baseline_FR_evoked_pupil_pvals = nan(169, 1);

%% Compute correlations
for i = 1:num_sessions
    cur_session = all_pyr_cleaned_data{i};

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
        bs_evoked_fr = results.all_bs_evoked_fr{i};
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

        % %% Scatterplot for each session
        % figure;
        % 
        % % 1. Evoked vs. baseline pupil
        % subplot(3, 2, 1);
        % hold on;
        % xaxis = residuals_baseline_pupil;
        % yaxis = bs_evoked_pupil;
        % scatter(xaxis, yaxis, 25, 'blue',...
        % 'filled', 'MarkerEdgeColor', 'w', 'LineWidth', 0.5);
        % yline(0, 'k--', 'LineWidth', 1.5);
        % xlabel('Baseline Pupil');
        % ylabel('Evoked Pupil');
        % title('Evoked vs. Baseline Pupil');
        % 
        % % 2. Evoked vs. baseline FR
        % subplot(3, 2, 2);
        % hold on;
        % xaxis = residuals_baseline_fr(:, u);
        % yaxis = bs_evoked_fr(:,u);
        % scatter(xaxis, yaxis, 25, 'red',...
        % 'filled', 'MarkerEdgeColor', 'w', 'LineWidth', 0.5);
        % yline(0, 'k--', 'LineWidth', 1.5);
        % xlabel('Baseline FR');
        % ylabel('Evoked FR');
        % title('Evoked vs. Baseline FR');
        % 
        % % 3. Baseline pupil vs. baseline FR
        % subplot(3, 2, 3);
        % hold on;
        % xaxis = residuals_baseline_fr(:, u);
        % yaxis = residuals_baseline_pupil;
        % scatter(xaxis, yaxis, 25, 'k',...
        % 'filled', 'MarkerEdgeColor', 'w', 'LineWidth', 0.5);
        % yline(0, 'k--', 'LineWidth', 1.5);
        % xlabel('Baseline FR');
        % ylabel('Baseline Pupil');
        % title('Baseline Pupil vs. Baseline FR');
        % 
        % % 4. Evoked pupil vs. evoked FR
        % subplot(3, 2, 4);
        % hold on;
        % xaxis = bs_evoked_fr(:,u);
        % yaxis = bs_evoked_pupil;
        % scatter(xaxis, yaxis, 25, 'k',...
        % 'filled', 'MarkerEdgeColor', 'w', 'LineWidth', 0.5);
        % yline(0, 'k--', 'LineWidth', 1.5);
        % xlabel('Evoked FR');
        % ylabel('Evoked Pupil');
        % title('Evoked Pupil vs. Evoked FR');
        % 
        % % 5. Evoked FR vs. baseline pupil
        % subplot(3, 2, 5);
        % hold on;
        % xaxis = residuals_baseline_pupil;
        % yaxis = bs_evoked_fr(:,u);
        % scatter(xaxis, yaxis, 25, 'k',...
        % 'filled', 'MarkerEdgeColor', 'w', 'LineWidth', 0.5);
        % yline(0, 'k--', 'LineWidth', 1.5);
        % xlabel('Baseline Pupil');
        % ylabel('Evoked FR');
        % title('Evoked FR vs. Baseline Pupil');
        % 
        % % 6. Evoked pupil vs. baseline FR
        % subplot(3, 2, 6);
        % hold on;
        % xaxis = residuals_baseline_fr(:, u);
        % yaxis = bs_evoked_pupil;
        % scatter(xaxis, yaxis, 25, 'k',...
        % 'filled', 'MarkerEdgeColor', 'w', 'LineWidth', 0.5);
        % yline(0, 'k--', 'LineWidth', 1.5);
        % xlabel('Baseline FR');
        % ylabel('Evoked Pupil');
        % title('Evoked Pupil vs. Baseline FR');
        % 
        % % Overall title
        % filename = cur_session.header.filename;
        % startIdx = strfind(filename, 'MM');
        % endIdx = strfind(filename, '.hdf5') - 1;
        % sessionName = filename(startIdx:endIdx);
        % sgtitle([sessionName, "Unit "+num2str(cur_session.spikes.id(u))],...
        %     'interpreter', 'none');
    end
end

%% Create figure
fig = figure;
% 1) Baseline-evoked pupil
median_rho = nanmedian(baseline_evoked_pupil);
significant_idx = baseline_evoked_pupil_pvals < 0.01;
subplot(3, 2, 1);
hold on;
xaxis = 1 + 2.*rand(169, 1);
scatter(xaxis(significant_idx), baseline_evoked_pupil(significant_idx), 50, ...
    'o', 'MarkerFaceColor', [0 174 239]./255, 'MarkerEdgeColor',...
    'none', 'MarkerFaceAlpha', 1);
scatter(xaxis(~significant_idx), baseline_evoked_pupil(~significant_idx), 50, ...
    'o', 'MarkerEdgeColor', [0 174 239]./255, 'MarkerEdgeColor',...
    'none', 'MarkerFaceAlpha', 0.2);
median_pval = signtest(baseline_evoked_pupil);
if median_pval < 0.01
    line_width = 6;
else
    line_width = 3;
end
plot(1 + [-0.5,2.5], [median_rho, median_rho], '-', 'Color', [0 174 239]./255,...
        'LineWidth', line_width);
plot([0, 4], [0, 0], ":k");
xlim([0, 4]);
ylim([-1, 1]);
xticks([]);
xticklabels([]);
ylim([-1, 1]);
ylabel('Spearman Correlation');
title('Pupil-Pupil');

% 2) Baseline-evoked firing rate
median_rho = nanmedian(baseline_evoked_FR);
significant_idx = baseline_evoked_FR_pvals < 0.01;
subplot(3, 2, 2);
hold on;
xaxis = 1 + 2.*rand(169, 1);
scatter(xaxis(significant_idx), baseline_evoked_FR(significant_idx), 50, ...
    'o', 'MarkerFaceColor', [237 28 36]./255, 'MarkerEdgeColor', 'none',...
    'MarkerFaceAlpha', 1);
scatter(xaxis(~significant_idx), baseline_evoked_FR(~significant_idx), 50, ...
    'o', 'MarkerEdgeColor', [237 28 36]./255, 'MarkerEdgeColor', 'none',...
    'MarkerFaceAlpha', 0.2);
median_pval = signtest(baseline_evoked_FR);
if median_pval < 0.01
    line_width = 6;
else
    line_width = 3;
end
plot(1 + [-0.5,2.5], [median_rho, median_rho], '-', 'Color', [237 28 36]./255,...
        'LineWidth', line_width);
plot([0, 4], [0, 0], ":k");
xlim([0, 4]);
ylim([-1, 1]);
xticks([]);
xticklabels([]);
ylim([-1, 1]);
ylabel('Spearman Correlation');
title('FR-FR');

% 3) Baseline pupil-baseline firing rate
median_rho = nanmedian(baseline_pupil_baseline_FR);
significant_idx = baseline_pupil_baseline_FR_pvals < 0.01;
subplot(3, 2, 3);
hold on;
xaxis = 1 + 2.*rand(169, 1);
scatter(xaxis(significant_idx), baseline_pupil_baseline_FR(significant_idx), 50, ...
    'o', 'MarkerFaceColor', [0.5 0.5 0.5], 'MarkerEdgeColor',...
    'none', 'MarkerFaceAlpha', 1);
scatter(xaxis(~significant_idx), baseline_pupil_baseline_FR(~significant_idx), 50, ...
    'o', 'MarkerEdgeColor', [0.5 0.5 0.5], 'MarkerEdgeColor',...
    'none', 'MarkerFaceAlpha', 0.3);
median_pval = signtest(baseline_pupil_baseline_FR);
if median_pval < 0.01
    line_width = 6;
else
    line_width = 3;
end
plot(1 + [-0.5,2.5], [median_rho, median_rho], '-', 'Color', 'k',...
        'LineWidth', line_width);
plot([0, 4], [0, 0], ":k");
xlim([0, 4]);
ylim([-1, 1]);
xticks([]);
xticklabels([]);
ylim([-1, 1]);
ylabel('Spearman Correlation');
title('Baseline');

% 4) Evoked FR vs. evoked pupil
median_rho = nanmedian(evoked_pupil_evoked_FR);
significant_idx = evoked_pupil_evoked_FR_pvals < 0.01;
subplot(3, 2, 4);
hold on;
xaxis = 1 + 2.*rand(169, 1);
scatter(xaxis(significant_idx), evoked_pupil_evoked_FR(significant_idx), 50, ...
    'o', 'MarkerFaceColor', [0.5 0.5 0.5], 'MarkerEdgeColor',...
    'none', 'MarkerFaceAlpha', 1);
scatter(xaxis(~significant_idx), evoked_pupil_evoked_FR(~significant_idx), 50, ...
    'o', 'MarkerFaceColor', [0.5 0.5 0.5], 'MarkerEdgeColor',...
    'none', 'MarkerFaceAlpha', 0.3);
median_pval = signtest(evoked_pupil_evoked_FR);
if median_pval < 0.01
    line_width = 6;
else
    line_width = 3;
end
plot(1 + [-0.5,2.5], [median_rho, median_rho], '-', 'Color', 'k',...
        'LineWidth', line_width);
plot([0, 4], [0, 0], ":k");
xlim([0, 4]);
ylim([-1, 1]);
xticks([]);
xticklabels([]);
ylim([-1, 1]);
ylabel('Spearman Correlation');
title('Evoked');

% 5) Evoked FR vs. baseline pupil
median_rho = nanmedian(evoked_FR_baseline_pupil);
significant_idx = evoked_FR_baseline_pupil_pvals < 0.01;
subplot(3, 2, 5);
hold on;
xaxis = 1 + 2.*rand(169, 1);
scatter(xaxis(significant_idx), evoked_FR_baseline_pupil(significant_idx), 50, ...
    'o', 'MarkerFaceColor', [0.5 0.5 0.5], 'MarkerEdgeColor',...
    'none', 'MarkerFaceAlpha', 1);
scatter(xaxis(~significant_idx), evoked_FR_baseline_pupil(~significant_idx), 50, ...
    'o', 'MarkerFaceColor', [0.5 0.5 0.5], 'MarkerEdgeColor',...
    'none', 'MarkerFaceAlpha', 0.3);
median_pval = signtest(evoked_pupil_evoked_FR);
if median_pval < 0.01
    line_width = 6;
else
    line_width = 3;
end
plot(1 + [-0.5,2.5], [median_rho, median_rho], '-', 'Color', 'k',...
        'LineWidth', line_width);
plot([0, 4], [0, 0], ":k");
xlim([0, 4]);
ylim([-1, 1]);
xticks([]);
xticklabels([]);
ylim([-1, 1]);
ylabel('Spearman Correlation');
title('Base P vs Evoked FR');

% 6) Baseline FR vs. evoked pupil
median_rho = nanmedian(baseline_FR_evoked_pupil);
significant_idx = baseline_FR_evoked_pupil_pvals < 0.01;
subplot(3, 2, 6);
hold on;
xaxis = 1 + 2.*rand(169, 1);
scatter(xaxis(significant_idx), baseline_FR_evoked_pupil(significant_idx), 50, ...
    'o', 'MarkerFaceColor', [0.5 0.5 0.5], 'MarkerEdgeColor',...
    'none', 'MarkerFaceAlpha', 1);
scatter(xaxis(~significant_idx), baseline_FR_evoked_pupil(~significant_idx), 50, ...
    'o', 'MarkerFaceColor', [0.5 0.5 0.5], 'MarkerEdgeColor',...
    'none', 'MarkerFaceAlpha', 0.3);
median_pval = signtest(evoked_pupil_evoked_FR);
if median_pval < 0.01
    line_width = 6;
else
    line_width = 3;
end
plot(1 + [-0.5,2.5], [median_rho, median_rho], '-', 'Color', 'k',...
        'LineWidth', line_width);
plot([0, 4], [0, 0], ":k");
xlim([0, 4]);
ylim([-1, 1]);
xticks([]);
xticklabels([]);
ylim([-1, 1]);
ylabel('Spearman Correlation');
title('Evoked P vs Base FR');