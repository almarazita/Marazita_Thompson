%% Batch plot pupil

num_sessions = length(all_pyr_cleaned_data);
low_h_baselines = nan(num_sessions, 1);
high_h_baselines = nan(num_sessions, 1);
low_h_evokeds = nan(num_sessions, 1);
high_h_evokeds = nan(num_sessions, 1);
for i = 1:num_sessions

    % Get session
    cur_session = all_pyr_cleaned_data{i};

    % Clean and save average baseline and evoked values across all trials
    cur_session = clean_pupil(cur_session);
    mdlBaseline = fitlm(cur_session.times.trial_begin, cur_session.baseline_pupil);
    residualsBaseline = mdlBaseline.Residuals.Raw;
    hazards = nonanunique(cur_session.values.hazard);
    for j = 1:length(hazards)
        h = hazards(j);

        h_data = residualsBaseline(cur_session.values.hazard == h);
        avg = nanmean(h_data);
        if h == 0.05
            low_h_baselines(i) = avg;
        else
            high_h_baselines(i) = avg;
        end

        h_data = cur_session.bs_evoked_pupil(cur_session.values.hazard == h);
        avg = nanmean(h_data);
        if h == 0.05
            low_h_evokeds(i) = avg;
        else
            high_h_evokeds(i) = avg;
        end
    end

    % % Plot
    % p = plot_pupil(cur_session);
    % 
    % % Save as PDF
    % filename = cur_session.header.filename;
    % startIdx = strfind(filename, 'MM');
    % endIdx = strfind(filename, '.hdf5') - 1;
    % sessionName = filename(startIdx:endIdx);
    % pdfFileName = sessionName+"_Pupil.pdf";
    % exportgraphics(p, pdfFileName, 'ContentType', 'vector');
    % close(p);

end

%% Population median baseline residual by switch rate
% Get switch rates
co = {[4 94 167]./255, [194 0 77]./255}; % Keep switch rate colors consistent

% Get median residual baseline pupil value for each condition
median_baseline = zeros(2, 1);
median_baseline(1) = nanmedian(low_h_baselines);
median_baseline(2) = nanmedian(high_h_baselines);
% Plot
baselines = [low_h_baselines, high_h_baselines];
subplot(1, 2, 1);
h = [0.05, 0.50];
for i = 1:2
    h = hazards(i);
    scatter(h + (rand(num_sessions, 1) - 0.5) * 0.25,...
        baselines(i), 50, co{i}, 'filled', 'MarkerFaceAlpha', 0.5); % Jittered data points
    hold on;
    line([-0.165, 0.165] + h, [median_baseline(i), median_baseline(i)],...
        'LineWidth', 3, 'Color', 'k'); % Median line
    hold on;
end
yline(0, 'k--', 'LineWidth', 1.5); % 0 line
% Add labels
xlabel('Switch Rate');
ylabel('Average Residual Baseline Pupil Diameter');
title('Baseline Pupil by Switch Rate');

%% Population median evoked pupil by switch rate
% Get median baseline-sbutracted evoked pupil value for each condition
median_evoked = zeros(2, 1);
median_evoked(1) = nanmedian(low_h_evokeds);
median_evoked(2) = nanmedian(high_h_evokeds);
% Plot
evokeds = [low_h_evokeds, high_h_evokeds];
subplot(1, 2, 2);
for i = 1:2
    h = hazards(i);
    scatter(h + (rand(num_sessions, 1) - 0.5) * 0.25,...
        evokeds(i), ...
        50, co{i}, 'filled', 'MarkerFaceAlpha', 0.5); % Jittered data points
    hold on;
    line([-0.165, 0.165] + h, [median_evoked(i), median_evoked(i)],...
        'LineWidth', 3, 'Color', 'k'); % Median line
    hold on;
end
yline(0, 'k--', 'LineWidth', 1.5); % 0 line
% Add labels
xlabel('Switch Rate');
ylabel('Average Evoked Pupil Diameter');
title('Evoked Pupil by Switch Rate');

% Add main title
sgtitle('All Sessions Pupil Data');

%% Check sample_on times summary statistics
% means = zeros(1, num_sessions);
% medians = zeros(1, num_sessions);
% stds = zeros(1, num_sessions);
% vars = zeros(1, num_sessions);
% mins = zeros(1, num_sessions);
% maxs = zeros(1, num_sessions);
% 
% for i = 1:num_sessions
% 
%     % Check variation in time window averaged over for baseline
%     cur_session = all_pyr_cleaned_data{i};
%     sample_on_times = cur_session.times.sample_on * 1000;
%     means(i) = nanmean(sample_on_times);
%     medians(i) = nanmedian(sample_on_times);
%     stds(i) = nanstd(sample_on_times);
%     vars(i) = var(sample_on_times, 'omitnan');
%     mins(i) = min(sample_on_times, [], 'omitnan');
%     maxs(i) = max(sample_on_times, [], 'omitnan');
% 
% end
% 
% summaryStats = table((1:num_sessions)', means', medians', stds', vars',...
%     mins', maxs', 'VariableNames', {'SessionNumber', 'Mean', 'Median',...
%     'StdDev', 'Variance', 'Min', 'Max'});