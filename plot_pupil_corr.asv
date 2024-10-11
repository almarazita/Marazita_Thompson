%function plot_pupil_corr(data_w_pupil)
%% Plot correlations between pupil diameter and firing rate

% Create figure
% fig = figure;

%% 1) Baseline firing rate residuals vs. baseline pupil residuals
% mdl_baseline_pupil = fitlm(data_w_pupil.times.trial_begin, data_w_pupil.baseline_pupil);
% residuals_baseline_pupil = mdl_baseline_pupil.Residuals.Raw;
% unit_ids = data_w_pupil.spikes.id;
% num_units = length(unit_ids);
% for u = 1:num_units
%     tmp_mean = new_plotBaselineDrift_AODR(data_w_pupil,u,'sample_on',500,[],[]);
% end

%% 2) Evoked baseline-subtracted pupil vs. baseline pupil residuals
% Calculate the Spearman rank correlation between baseline-subtracted
% evoked pupil diameter and residual baseline pupil diameter for each
% session
num_sessions = length(all_pyr_cleaned_data);
all_rhos = nan(num_sessions, 1);
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

    % Correlation by switch rate
    low_h_residualsBaseline = residualsBaseline(cur_sesion.values.hazard == 0.05);
    low_h_bs_evoked = bs_evoked(cur_sesion.values.hazard == 0.05);
    if ~isempty(low_h_residualsBaseline)
        [rho, pval] = corr(low_h_residualsBaseline, low_h_bs_evoked,...
            'Type', 'Spearman', 'Rows', 'complete');
        low_h_rhos(i) = rho;
    end

    high_h_residualsBaseline = residualsBaseline(cur_sesion.values.hazard == 0.50);
    high_h_bs_evoked = bs_evoked(cur_sesion.values.hazard == 0.50);
    if ~isempty(high_h_residualsBaseline)
        [rho, pval] = corr(high_h_residualsBaseline, high_h_bs_evoked,...
            'Type', 'Spearman', ['Ro' ...
            'ws'], 'complete');
        high_h_rhos(i) = rho;
    end
end

% Plot the distribution of all coefficients
figure;
subplot(1,3,1)
histogram(all_rhos, 'FaceColor', 'w');
xline(0, 'k--');
xlim([-1, 1]);
xlabel('Spearman Rank Correlation Coefficient');
ylabel('Number of Sessions');
title('Evoked vs. Baseline Pupil');

subplot(1,3,2)
histogram(low_h_rhos, 'FaceColor', [4 94 167]./255);
xline(0, 'k--');
xlim([-1, 1]);
xlabel('Spearman Rank Correlation Coefficient');
ylabel('Number of Sessions');
title('Evoked vs. Baseline Pupil');

subplot(1,3,3)
histogram(high_h_rhos, 'FaceColor', [194 0 77]./255);
xline(0, 'k--');
xlim([-1, 1]);
xlabel('Spearman Rank Correlation Coefficient');
ylabel('Number of Sessions');
title('Evoked vs. Baseline Pupil');

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

%% 3) Evoked baseline-subtracted firing rate vs.
%  baseline baseline firing rate residuals