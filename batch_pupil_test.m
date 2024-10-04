%% Plot population pupil

num_sessions = length(all_pyr_cleaned_data);

low_h_baselines = nan(num_sessions, 1);
high_h_baselines = nan(num_sessions, 1);
low_h_evokeds = nan(num_sessions, 1);
high_h_evokeds = nan(num_sessions, 1);

for i = 1:num_sessions

    cur_session = all_pyr_cleaned_data{i};
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

figure;
%% Population median baseline residual by switch rate
% Get switch rates
co = {[4 94 167]./255, [194 0 77]./255}; % Keep switch rate colors consistent

% Get median residual baseline pupil value for each condition
median_baseline = zeros(2, 1);
median_baseline(1) = nanmedian(low_h_baselines);
median_baseline(2) = nanmedian(high_h_baselines);
% Plot
baselines = [low_h_baselines, high_h_baselines];
subplot(2, 2, 1);
h = [0.05, 0.50];
for i = 1:2
    h = hazards(i);
    scatter(h + (rand(num_sessions, 1) - 0.5) * 0.25,...
        baselines(:,i), 50, co{i}, 'filled', 'MarkerFaceAlpha', 0.5); % Jittered data points
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
ax_handles(1) = gca;

%% Average baseline residual by condition
limits = [min([low_h_baselines; high_h_baselines])*1.1,...
    max([low_h_baselines; high_h_baselines])*1.1];
subplot(2,2,2);
xlim(limits);
ylim(limits);
hold on;
plot(limits, limits, 'k--', 'LineWidth', 1.5);
fill([limits(1) limits(2) limits(2)],...
    [limits(1) limits(2) limits(1)], co{1},...
    'FaceAlpha', 0.3, 'EdgeColor', 'none');
fill([limits(1) limits(2) limits(1)],...
    [limits(1) limits(2) limits(2)], co{2},...
    'FaceAlpha', 0.3, 'EdgeColor', 'none');
scatter(low_h_baselines, high_h_baselines, 'k', 'filled');
num_above = sum(high_h_baselines > low_h_baselines);
num_below = sum(high_h_baselines <= low_h_baselines);
text(0.2, 0.4,...
    ['N = ' num2str(num_above)], 'Color', 'k', 'FontSize', 10);
text(0.4, 0.3,...
    ['N = ' num2str(num_below)], 'Color', 'k', 'FontSize', 10);
xlabel('Low switch rate baseline pupil');
ylabel('High switch rate baseline pupil');
hold off;

%% Population median evoked pupil by switch rate
% Get median baseline-sbutracted evoked pupil value for each condition
median_evoked = zeros(2, 1);
median_evoked(1) = nanmedian(low_h_evokeds);
median_evoked(2) = nanmedian(high_h_evokeds);
% Plot
evokeds = [low_h_evokeds, high_h_evokeds];
subplot(2, 2, 3);
for i = 1:2
    h = hazards(i);
    scatter(h + (rand(num_sessions, 1) - 0.5) * 0.25,...
        evokeds(:,i), ...
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
ax_handles(2) = gca;

%% Average evoked pupil by condition
limits = [min([low_h_evokeds; high_h_evokeds])*1.1,...
    max([low_h_evokeds; high_h_evokeds])*1.1];
subplot(2,2,4);
xlim(limits);
ylim(limits);
hold on;
plot(limits, limits, 'k--', 'LineWidth', 1.5);
fill([limits(1) limits(2) limits(2)],...
    [limits(1) limits(2) limits(1)], co{1},...
    'FaceAlpha', 0.3, 'EdgeColor', 'none');
fill([limits(1) limits(2) limits(1)],...
    [limits(1) limits(2) limits(2)], co{2},...
    'FaceAlpha', 0.3, 'EdgeColor', 'none');
scatter(low_h_evokeds, high_h_evokeds, 'k', 'filled');
num_above = sum(high_h_evokeds > low_h_evokeds);
num_below = sum(high_h_evokeds <= low_h_evokeds);
text(0.5, 0.7,...
    ['N = ' num2str(num_above)], 'Color', 'k', 'FontSize', 10);
text(0.7, 0.5,...
    ['N = ' num2str(num_below)], 'Color', 'k', 'FontSize', 10);
xlabel('Low switch rate evoked pupil');
ylabel('High switch rate evoked pupil');
hold off;

%% Whole plot
% Set y axis limits to be the same
ylims = cell2mat(get(ax_handles, 'Ylim'));
ylim_new = [min(ylims(:,1)), max(ylims(:,2))];
set(ax_handles, 'Ylim', ylim_new);

% Add main title
sgtitle('All Sessions Pupil Data');