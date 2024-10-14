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

    % Correlation by switch rate
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
% subplot(1,3,1)
xaxis = rand(num_sessions, 1);
scatter(xaxis(significant_idx), all_rhos(significant_idx), 50, ...
    'filled', 'MarkerFaceColor', 'r');
scatter(xaxis(~significant_idx), all_rhos(~significant_idx), 50, ...
    'MarkerFaceColor', 'r');
line([min(xaxis), max(xaxis)], [median_rho, median_rho],...
         'LineWidth', 4, 'Color', 'k');
yline(0, 'k--');
xlim([-0.5, 1.5]);
xticks([]);
xticklabels([]);
ylim([-1, 1]);
ylabel('Spearman Rank Correlation Coefficient');
title('Evoked vs. Baseline Pupil');

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

% Plot
% co = {[4 94 167]./255, [194 0 77]./255}; % Blue = low, red = high
% num_trials = data_w_pupil.header.numTrials;
% colors = zeros(num_trials, 3);
% for tr = 1:num_trials
%     if data_w_pupil.values.hazard(tr) == 0.05
%         colors(tr, :) = co{1};
%     elseif data_w_pupil.values.hazard(tr) == 0.50
%         colors(tr, :) = co{2};
%     else
%         colors(tr, :) = [0, 0, 0];
%     end
% end
% scatter(residualsBaseline, data_w_pupil.bs_evoked_pupil, 50, colors,...
%     'filled', 'MarkerEdgeColor', 'w', 'LineWidth', 0.5);
% % Label
% yline(0, 'k--', 'LineWidth', 1.5);
% xlabel('Residual Baseline Pupil Diameter');
% ylabel('Evoked Pupil Diameter');
% title('Evoked vs. Baseline');

%% 2) Baseline firing rate residuals vs. baseline pupil residuals
all_rhos = nan(169, 1); % Total units
all_pvals = nan(169, 1);

overall_unit = 1;
for i = 1:num_sessions
    cur_session = all_pyr_cleaned_data{i};

    mdl_baseline_pupil = fitlm(cur_session.times.trial_begin, cur_session.baseline_pupil);
    residuals_baseline_pupil = mdl_baseline_pupil.Residuals.Raw;
    
    num_trials = cur_session.header.numTrials;
    sample_on_idxs = nan(num_trials, 1);
    for tr = 1:num_trials
        sample_on_idxs(tr) = new_getEventIndex(cur_session, tr, 19); % sample_on = column 19
    end
    
    unit_ids = cur_session.spikes.id;
    num_units = length(unit_ids);
    baseline_fr = nan(num_units, num_trials);
    cur_rhos = nan(num_units, 1);
    for u = 1:num_units
        unit_spikes = squeeze(cur_session.binned_spikes(u,:,:)); % ms x trials
        for tr = 1:num_trials
            sample_on_idx = sample_on_idxs(tr);
            if sample_on_idx > 500 && ~isnan(sample_on_idx) && ~isnan(cur_session.ids.choice(tr)) % Valid, completed trials
                baseline_fr(u, tr) = mean(unit_spikes((sample_on_idx - 500):(sample_on_idx - 1), tr)); % Avg fr 500ms before sample_on
            end
        end
        [rho, pval] = corr(residuals_baseline_pupil, baseline_fr(u, :)',...
            'Type', 'Spearman', 'Rows', 'complete');
        all_rhos(overall_unit) = rho;
        all_pvals(overall_unit) = pval;
        overall_unit = overall_unit + 1;
    end
end


%% 3) Evoked baseline-subtracted firing rate vs.
%  baseline baseline firing rate residuals