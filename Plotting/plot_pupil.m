function [fig] = plot_pupil(all_pyr_cleaned_data, session_num, method, will_save)
%% Plot cleaned baseline and evoked pupil data for a session, optionally saving as PDF

% Select method for computing evoked pupil response
valid_methods = ["bs", "change", "resid"];
if isempty(method) || ~ismember(method, valid_methods)
    method = "bs";
end

% Default to not saving
if nargin < 4
    will_save = false;
end

% Select session
data_w_pupil = all_pyr_cleaned_data{session_num};

% Create figure
fig = figure;

%% 1) Baseline pupil vs. time
% Plot
subplot(2, 2, 1);
co = {[4 94 167]./255, [194 0 77]./255}; % Blue = low, red = high
num_trials = data_w_pupil.header.validTrials;
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
scatter(data_w_pupil.times.trial_begin, data_w_pupil.baseline_pupil, ...
    30, colors, 'filled');
yline(0, 'k--', 'LineWidth', 1.5);
% Add labels
xlabel('Trial Start Time (ms)');
ylabel('Baseline Pupil Diameter');
title('Baseline Pupil Drift');

%% 2) Evoked vs. baseline residuals
% Regress baseline against time and get evoked with chosen method
mdlBaseline = fitlm(data_w_pupil.times.trial_begin, data_w_pupil.baseline_pupil);
residualsBaseline = mdlBaseline.Residuals.Raw;
if method == "bs"
    evoked = data_w_pupil.evoked_max_pupil' - data_w_pupil.baseline_pupil;
elseif method == "change"
    all_changes = get_pupil_change(all_pyr_cleaned_data);
    evoked = all_changes{session_num};
else
    all_resids = get_pupil_resid(all_pyr_cleaned_data);
    evoked = all_resids{session_num};
end
% Plot
subplot(2, 2, 2);
scatter(residualsBaseline, evoked, 50, colors,...
    'filled', 'MarkerEdgeColor', 'w', 'LineWidth', 0.5);
% Label
yline(0, 'k--', 'LineWidth', 1.5);
xlabel('Residual Baseline Pupil Diameter');
ylabel('Evoked Pupil Diameter');
title('Evoked vs. Baseline');

%% 3) Median baseline residual by switch rate
% Get switch rates
hazards = nonanunique(data_w_pupil.values.hazard);
if hazards(1) == 0.05
    co = {[4 94 167]./255, [194 0 77]./255}; % Keep switch rate colors consistent
else
    co = {[194 0 77]./255, [4 94 167]./255};
end
num_hazards = length(hazards);
% Get median residual baseline pupil value for each condition
median_baseline = zeros(num_hazards, 1);
for i = 1:num_hazards
    h = hazards(i);
    h_data = residualsBaseline(data_w_pupil.values.hazard == h);
    median_baseline(i) = nanmedian(h_data);
end
% Plot
subplot(2, 2, 3);
for i = 1:num_hazards
    h = hazards(i);
    scatter(h + (rand(sum(data_w_pupil.values.hazard == h), 1) - 0.5) * 0.25, ...
        residualsBaseline(data_w_pupil.values.hazard == h), ...
        50, co{i}, 'filled', 'MarkerFaceAlpha', 0.5); % Jittered data points
    hold on;
    line([-0.165, 0.165] + h, [median_baseline(i), median_baseline(i)],...
        'LineWidth', 3, 'Color', 'k'); % Median line
    hold on;
end
yline(0, 'k--', 'LineWidth', 1.5); % 0 line
% Add labels
xlabel('Switch Rate');
ylabel('Residual Baseline Pupil Diameter');
title('Baseline Pupil by Switch Rate');

%% 4) Median evoked pupil by switch rate
% Get median baseline-sbutracted evoked pupil value for each condition
median_evoked = zeros(num_hazards, 1);
for i = 1:num_hazards
    h = hazards(i);
    h_data = evoked(data_w_pupil.values.hazard == h);
    median_evoked(i) = nanmedian(h_data);
end
% Plot
subplot(2, 2, 4);
for i = 1:num_hazards
    h = hazards(i);
    scatter(h + (rand(sum(data_w_pupil.values.hazard == h), 1) - 0.5) * 0.25, ...
        evoked(data_w_pupil.values.hazard == h), ...
        50, co{i}, 'filled', 'MarkerFaceAlpha', 0.5); % Jittered data points
    hold on;
    line([-0.165, 0.165] + h, [median_evoked(i), median_evoked(i)],...
        'LineWidth', 3, 'Color', 'k'); % Median line
    hold on;
end
yline(0, 'k--', 'LineWidth', 1.5); % 0 line
% Add labels
xlabel('Switch Rate');
ylabel('Evoked Pupil Diameter');
title('Evoked Pupil by Switch Rate');

% Add main title
filename = data_w_pupil.header.filename;
startIdx = strfind(filename, 'MM');
endIdx = strfind(filename, '.hdf5') - 1;
sessionName = filename(startIdx:endIdx);
sgtitle({sessionName, 'Pupil Data'}, 'Interpreter', 'none')

%% Optionally, save as PDF
if will_save
    pdfFileName = sessionName+"_Pupil.pdf";
    exportgraphics(fig, pdfFileName, 'ContentType', 'vector');
    close(fig);
end