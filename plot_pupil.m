% Plot baseline diameter as a function as the time that the trial started.
figure;
scatter(data_w_pupil.times.trial_begin, data_w_pupil.baseline_pupil, ...
    'filled', 'MarkerFaceColor', 'k');
yline(0, 'k--', 'LineWidth', 1.5);
xlabel('Trial Start Time (s)');
ylabel('Baseline Pupil Diameter');
filename = data_w_pupil.header.filename;
startIdx = strfind(filename, 'MM');
endIdx = strfind(filename, '.hdf5') - 1;
sessionName = filename(startIdx:endIdx);
plot_title = {sessionName, 'Baseline Pupil Drift'};
title(plot_title, 'Interpreter', 'none');

% Plot the pupil data for a given session or neuron to look at low vs. high
% hazard.
co = {[4 94 167]./255, [194 0 77]./255}; % Blue = low, red = high
num_trials = data_w_pupil.header.numTrials;
colors = zeros(num_trials, 3);
for tr = 1:num_trials
    if data_w_pupil.values.hazard(tr) == 0.05
        colors(tr, :) = co{1};
    elseif data_w_pupil.values.hazard(tr) == 0.50
        colors(tr, :) = co{2};
    else
        colors(tr, :) = [0, 0, 0];
    end
end
figure;
evoked_pupil = data_w_pupil.evoked_pupil - data_w_pupil.baseline_pupil;
scatter(data_w_pupil.times.trial_begin, evoked_pupil, 50, ...
    colors, 'filled');
yline(0, 'k--', 'LineWidth', 1.5);
xlabel('Trial Start Time (s)');
ylabel('Evoked Pupil Diameter');
plot_title = {sessionName, 'Evoked Pupil Diameter'};
title(plot_title, 'Interpreter', 'none');

% Evoked over time, colored by hazard, minus effect of time
mdl = fitlm(data_w_pupil.times.trial_begin, evoked_pupil);
predicted = mdl.Fitted;
evoked_no_drift = data_w_pupil.evoked_pupil - predicted;
figure;
scatter(data_w_pupil.times.trial_begin, evoked_no_drift, 50, ...
    colors, 'filled');
yline(0, 'k--', 'LineWidth', 1.5);
xlabel('Trial Start Time (s)');
ylabel('Evoked Pupil Diameter');
plot_title = {sessionName, 'Evoked Pupil Diameter (no drift)'};
title(plot_title, 'Interpreter', 'none');

% Evoked vs. baseline
figure;
scatter(data_w_pupil.baseline_pupil, evoked_pupil, 50, colors, 'filled');
yline(0, 'k--', 'LineWidth', 1.5);
xlabel('Baseline Pupil Diameter');
ylabel('Evoked Pupil Diameter');
plot_title = {sessionName, 'Evoked vs. Baseline'};
title(plot_title, 'Interpreter', 'none');

% Evoked vs. baseline residuals
residualsEvoked = mdl.Residuals.Raw;
mdlBaseline = fitlm(data_w_pupil.times.trial_begin, data_w_pupil.baseline_pupil);
residualsBaseline = mdlBaseline.Residuals.Raw;
figure;
scatter(residualsBaseline, residualsEvoked, 50, colors, 'filled');
yline(0, 'k--', 'LineWidth', 1.5);
xlabel('Baseline Pupil Diameter Residuals');
ylabel('Evoked Pupil Diameter Residuals');
plot_title = {sessionName, 'Evoked vs. Baseline Residuals'};
title(plot_title, 'Interpreter', 'none');

% Plot average evoked pupil diameter for each hazard condition
hazards = nonanunique(data_w_pupil.values.hazard);
num_hazards = length(hazards);
avg_evoked = zeros(num_hazards, 1);
sem_evoked = zeros(num_hazards, 1);
for i = 1:num_hazards
    h = hazards(i);
    h_data = evoked_pupil(data_w_pupil.values.hazard == h);
    avg_evoked(i) = nanmean(h_data);
    sem_evoked = nanstd(h_data) / sqrt(length(h_data));
end
figure;
hold on;
hBar = bar(hazards, avg_evoked, 'FaceColor', 'flat');
for i = 1:length(hazards)
    hBar.CData(i, :) = co{i};
end
errorbar(hazards, avg_evoked, sem_evoked, 'k', 'LineWidth', 1.5);
for i = 1:num_hazards
    h = hazards(i);
    scatter(h + (rand(sum(data_w_pupil.values.hazard == h), 1) - 0.5) * 0.3, ...
        evoked_pupil(data_w_pupil.values.hazard == h), ...
        50, co{i}, 'filled', 'MarkerFaceAlpha', 0.5);
end
xlabel('Switch Rate');
ylabel('Average Evoked Pupil Diameter');
plot_title = {sessionName, 'Evoked Pupil by Switch Rate'};
title(plot_title, 'Interpreter', 'none');

% Try again with only variation unexplained by time or baseline
tbl = table(data_w_pupil.times.trial_begin, data_w_pupil.baseline_pupil,...
    evoked_pupil, 'VariableNames', {'TrialBegin', 'Baseline', 'Evoked'});
mdl = fitlm(tbl, 'Evoked ~ TrialBegin + Baseline');
residuals = mdl.Residuals.Raw;
for i = 1:num_hazards
    h = hazards(i);
    h_data = residuals(data_w_pupil.values.hazard == h);
    avg_evoked(i) = nanmean(h_data);
    sem_evoked = nanstd(h_data) / sqrt(length(h_data));
end
figure;
hold on;
hBar = bar(hazards, avg_evoked, 'FaceColor', 'flat');
for i = 1:length(hazards)
    hBar.CData(i, :) = co{i};
end
errorbar(hazards, avg_evoked, sem_evoked, 'k', 'LineWidth', 1.5);
for i = 1:num_hazards
    h = hazards(i);
    scatter(h + (rand(sum(data_w_pupil.values.hazard == h), 1) - 0.5) * 0.3, ...
        evoked_pupil(data_w_pupil.values.hazard == h), ...
        50, co{i}, 'filled', 'MarkerFaceAlpha', 0.5);
end
xlabel('Switch Rate');
ylabel('Average Evoked Pupil Diameter');
plot_title = {sessionName, 'Evoked Pupil by Switch Rate (removing effects)'};
title(plot_title, 'Interpreter', 'none');

% Baseline by switch rate without drift
avg_baseline = zeros(num_hazards, 1);
sem_baseline = zeros(num_hazards, 1);
for i = 1:num_hazards
    h = hazards(i);
    h_data = residualsBaseline(data_w_pupil.values.hazard == h);
    avg_baseline(i) = nanmean(h_data);
    sem_baseline = nanstd(h_data) / sqrt(length(h_data));
end
figure;
hold on;
hBar = bar(hazards, avg_baseline, 'FaceColor', 'flat');
for i = 1:length(hazards)
    hBar.CData(i, :) = co{i};
end
errorbar(hazards, avg_baseline, sem_baseline, 'k', 'LineWidth', 1.5);
for i = 1:num_hazards
    h = hazards(i);
    scatter(h + (rand(sum(data_w_pupil.values.hazard == h), 1) - 0.5) * 0.3, ...
        data_w_pupil.baseline_pupil(data_w_pupil.values.hazard == h), ...
        50, co{i}, 'filled', 'MarkerFaceAlpha', 0.5);
end
xlabel('Switch Rate');
ylabel('Average Baseline Pupil Diameter');
plot_title = {sessionName, 'Baseline Pupil by Switch Rate (no drift)'};
title(plot_title, 'Interpreter', 'none');