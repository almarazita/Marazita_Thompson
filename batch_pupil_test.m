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
subplot(2,2,2);
scatter(low_h_baselines, high_h_baselines,'filled');
hold on;
xlimits = xlim;
ylimits= ylim;
maxlimits = [min(xlimits(1), ylimits(1)), max(xlimits(2), ylimits(2))];
plot(maxlimits, maxlimits, 'k--', 'LineWidth', 1.5);
% unity_line_x = linspace(min(xlimits), max(xlimits), 100);
% unity_line_y = unity_line_x;
% plot(unity_line_x, unity_line_y, 'k--', 'LineWidth', 1.5);
fill([xlimits(1) xlimits(2) xlimits(2)],...
    [xlimits(1) xlimits(2) xlimits(1)], co{1},...
    'FaceAlpha', 0.3, 'EdgeColor', 'none');
fill([xlimits(1) xlimits(2) xlimits(1)],...
    [xlimits(1) xlimits(2) xlimits(2)], co{2},...
    'FaceAlpha', 0.3, 'EdgeColor', 'none');
num_above = sum(high_h_baselines > low_h_baselines);
num_below = sum(high_h_baselines <= low_h_baselines);
text(xlimits(1) * 1.1, ylimits(2) * 0.9,...
    ['N = ' num2str(num_above)], 'Color', 'k', 'FontSize', 10);
text(xlimits(2) * 0.9, ylimits(1) * 1.1,...
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

% Set y axis limits to be the same
ylim = cell2mat(get(ax_handles, 'Ylim'));
ylim_new = [min(ylim(:,1)), max(ylim(:,2))];
set(ax_handles, 'Ylim', ylim_new);

% Add main title
sgtitle('All Sessions Pupil Data');