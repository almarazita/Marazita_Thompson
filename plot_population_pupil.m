function plot_population_pupil(all_pyr_cleaned_data, method, alltrials)
%% Plot population pupil

% Select method for computing evoked pupil response
valid_methods = ["bs", "change"];
if isempty(method) || ~ismember(method, valid_methods)
    method = "bs";
end

if isempty(alltrials)
    alltrials = false;
end

num_sessions = length(all_pyr_cleaned_data);

all_hazards = zeros(num_sessions, 1650);
if ~alltrials
    low_h_baselines = nan(num_sessions, 1);
    high_h_baselines = nan(num_sessions, 1);
    low_h_evokeds = nan(num_sessions, 1);
    high_h_evokeds = nan(num_sessions, 1);
else
    total_trials = 0;
    for i = 1:num_sessions
        total_trials = total_trials + all_pyr_cleaned_data{i}.header.numTrials;
    end
    
    low_h_baselines = nan(total_trials, 1);
    high_h_baselines = nan(total_trials, 1);
    low_h_evokeds = nan(total_trials, 1);
    high_h_evokeds = nan(total_trials, 1);

    low_h_tr = 1; % Keep track of position in master list
    high_h_tr = 1;
end

if method == "change"
    pupil_change = get_pupil_change(all_pyr_cleaned_data);
end

% For each session
for i = 1:num_sessions

    % Get struct and baseline residuals
    cur_session = all_pyr_cleaned_data{i};
    num_trials = cur_session.header.numTrials;

    mdlBaseline = fitlm(cur_session.times.trial_begin, cur_session.baseline_pupil);
    residualsBaseline = mdlBaseline.Residuals.Raw;
    cur_hazard = cur_session.values.hazard;
    all_hazards(i, 1:num_trials) = cur_hazard;

    % For each switch rate
    hazards = nonanunique(cur_hazard);
    for j = 1:length(hazards)
        h = hazards(j);

        % Get the average baseline residual
        h_data = residualsBaseline(cur_hazard == h);
        num_trials = length(h_data);
        if h == 0.05
            if ~alltrials
                low_h_baselines(i) = nanmean(h_data);
            else
                low_h_baselines(low_h_tr:low_h_tr+num_trials-1) = h_data;
            end
        else
            if ~alltrials
                high_h_baselines(i) = nanmean(h_data);
            else
                high_h_baselines(high_h_tr:high_h_tr+num_trials-1) = h_data;
            end
        end

        % Get the average evoked
        if method == "bs"
            h_data = cur_session.bs_evoked_pupil(cur_hazard == h);
        elseif method == "change"
            h_data = pupil_change{i}(cur_hazard == h);
        end

        if h == 0.05
            if ~alltrials
                low_h_evokeds(i) = nanmean(h_data);
            else
                low_h_evokeds(low_h_tr:low_h_tr+num_trials-1) = h_data;
                low_h_tr = low_h_tr + num_trials;
            end
        else
            if ~alltrials
                high_h_evokeds(i) = nanmean(h_data);
            else
                high_h_evokeds(high_h_tr:high_h_tr+num_trials-1) = h_data;
                high_h_tr = high_h_tr + num_trials;
            end
        end

    end

    %% Plot pupil data for session
    plot_pupil(all_pyr_cleaned_data, i, method);

end

%% Check the order of switch rates in each session
% cmap = [[0 0 0];
%     [1 1 1];
%     [4 94 167]./ 255;
%     [194 0 77]./ 255];
% figure;
% heatmap = all_hazards;
% heatmap(isnan(heatmap)) = -1;
% heatmap(heatmap==0.05) = 1;
% heatmap(heatmap==0.50) = 2;
% imagesc(heatmap);
% colormap(cmap);
% xlabel('Trial Number');
% ylabel('Session Number');
% title('Switch Rate Task Structure');
% caxis([-1 0.50]);
% colorbar('Ticks', [-1, 1, 2], ...
%     'TickLabels', {'NaN', 'h = 0.05', 'h = 0.50'}, ...
%     'Location', 'eastoutside');
% set(gca, 'box', 'off');
% set(gca, 'TickDir', 'out');

%% Check baseline-subtracted evoked over time
% for i = 1:num_sessions
% 
%     subplot_num = mod(i, 9);
%     if subplot_num == 1
%         figure;
%     end
%     if subplot_num == 0
%         subplot_num = 9;
%     end
%     subplot(3, 3, subplot_num)
% 
%     cur_session = all_pyr_cleaned_data{i};
%     num_trials = cur_session.header.numTrials;
%     bs_evoked = cur_session.bs_evoked_pupil;
%     cur_hazard = cur_session.values.hazard;
% 
%     co = {[4 94 167]./255, [194 0 77]./255}; % Blue = low, red = high
%     colors = zeros(num_trials, 3);    
%     for tr = 1:num_trials
%         if cur_hazard(tr) == 0.05
%             colors(tr, :) = co{1};
%         elseif cur_hazard(tr) == 0.50
%             colors(tr, :) = co{2};
%         else
%             colors(tr, :) = [0, 0, 0];
%         end
%     end
%     xaxis = 1:num_trials;
%     yaxis = bs_evoked';
%     for tr = 1:length(xaxis)-1
%         plot(xaxis(tr:tr+1), yaxis(tr:tr+1), 'Color', colors(tr, :));
%         hold on;
%     end
%     yline(0, 'k--', 'LineWidth', 1.5);
%     xlabel('Trial Number');
%     ylabel('Evoked Pupil Diameter');
%     filename = cur_session.header.filename;
%     startIdx = strfind(filename, 'MM');
%     endIdx = strfind(filename, '.hdf5') - 1;
%     sessionName = filename(startIdx:endIdx);
%     title(sessionName, 'Interpreter', 'none');
% end

%% Population median baseline residual by switch rate
figure;
% Get median residual baseline pupil value for each condition
median_baseline = zeros(2, 1);
median_baseline(1) = nanmedian(low_h_baselines);
median_baseline(2) = nanmedian(high_h_baselines);
% Plot
subplot(2, 2, 1);
baselines = [low_h_baselines, high_h_baselines];
if alltrials
    co = [[4 94 167]./255; ...
        [194 0 77]./255]; % Keep switch rate colors consistent
    violin(baselines, 'xlabel', {'Low Switch', 'High Switch'},...
        'facecolor', co, 'mc', '', 'medc', 'k');
else
    switch_rates = [0.05, 0.50];
    for i = 1:2
        h = switch_rates(i);
        co = {[4 94 167]./255, [194 0 77]./255};
        scatter(h + (rand(num_sessions, 1) - 0.5) * 0.25,...
            baselines(:,i), 50, co{i}, 'filled', 'MarkerFaceAlpha', 0.5); % Jittered data points
        hold on;
        line([-0.165, 0.165] + h, [median_baseline(i), median_baseline(i)],...
            'LineWidth', 3, 'Color', 'k'); % Median line
        hold on;
    end
end
yline(0, 'k--', 'LineWidth', 1.5); % 0 line
% Add labels
xlabel('Switch Rate');
ylabel('Average Residual Baseline Pupil Diameter');
title('Baseline Pupil by Switch Rate');
ax_handles(1) = gca;

%% Bootstrap test statistic
% If value is > 95% 
% observation = median_baseline(2) - median_baseline(1);
% all_baselines = [low_h_baselines; high_h_baselines];
% num_more_extreme = 0;
% for simulation = 1:1000
%     shuffled_data = all_baselines(randperm(length(all_baselines))); % Change to total_trials if plotting that way
%     resampled_low = shuffled_data(1:length(low_h_baselines));
%     resampled_high = shuffled_data(length(low_h_baselines)+1:end);
%     difference = nanmedian(resampled_high) - nanmedian(resampled_low);
%     if difference >= observation
%         num_more_extreme = num_more_extreme + 1;
%     end
% end
% fprintf('Observed baseline increase: %.4f\n', observation);
% fprintf('p-value: %.4f\n', num_more_extreme/1000);

%% Average baseline residual by switch rate (scatterplot)
if ~alltrials
    subplot(2,2,2);
    co = {[4 94 167]./255, [194 0 77]./255};
    limits = [-0.6, 1];
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
    axis square;
    box on;
    hold off;
end

%% Population median evoked pupil by switch rate
% Get median baseline-sbutracted evoked pupil value for each condition
median_evoked = zeros(2, 1);
median_evoked(1) = nanmedian(low_h_evokeds);
median_evoked(2) = nanmedian(high_h_evokeds);
% Plot
evokeds = [low_h_evokeds, high_h_evokeds];
subplot(2, 2, 3);
if alltrials
    co = [[4 94 167]./255; ...
        [194 0 77]./255];
    violin(evokeds, 'xlabel', {'Low Switch', 'High Switch'},...
        'facecolor', co, 'mc', '', 'medc', 'k');
else
    co = {[4 94 167]./255, [194 0 77]./255};
    switch_rates = [0.05, 0.50];
    for i = 1:2
        h = switch_rates(i);
        scatter(h + (rand(num_sessions, 1) - 0.5) * 0.25,... % Change to total_trials if plotting that way
            evokeds(:,i), ...
            50, co{i}, 'filled', 'MarkerFaceAlpha', 0.5); % Jittered data points
        hold on;
        line([-0.165, 0.165] + h, [median_evoked(i), median_evoked(i)],...
            'LineWidth', 3, 'Color', 'k'); % Median line
        hold on;
    end
end
yline(0, 'k--', 'LineWidth', 1.5); % 0 line
% Add labels
xlabel('Switch Rate');
ylabel('Average Evoked Pupil Diameter');
title('Evoked Pupil by Switch Rate');
ax_handles(2) = gca;

%% Bootstrap p-value
% observation = median_evoked(2) - median_evoked(1);
% all_evokeds = [low_h_evokeds; high_h_evokeds];
% num_more_extreme = 0;
% for simulation = 1:1000
%     shuffled_data = all_evokeds(randperm(length(all_evokeds)));
%     resampled_low = shuffled_data(1:length(low_h_evokeds));
%     resampled_high = shuffled_data(length(low_h_evokeds)+1:end);
%     difference = nanmedian(resampled_high) - nanmedian(resampled_low);
%     if difference >= observation
%         num_more_extreme = num_more_extreme + 1;
%     end
% end
% fprintf('Observed evoked increase: %.4f\n', observation);
% fprintf('p-value: %.4f\n', num_more_extreme/1000);

%% Average evoked pupil by switch rate (scatterplot)
if ~alltrials
    subplot(2,2,4);
    co = {[4 94 167]./255, [194 0 77]./255};
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
    axis square;
    box on;
    hold off;
end

%% Evoked increase vs. baseline increase
if ~alltrials
    baseline_increases = high_h_baselines - low_h_baselines;
    evoked_increases = high_h_evokeds - low_h_evokeds;
    figure;
    hold on;
    scatter(baseline_increases, evoked_increases, 'k', 'filled');
    xline(0, 'k--');
    yline(0, 'k--');
    xlabel('Average baseline pupil increase');
    ylabel('Average evoked pupil increase');
    axis square;
    box on;
    hold off;
end

%% Whole plot
% Set y axis limits to be the same
ylims = cell2mat(get(ax_handles, 'Ylim'));
ylim_new = [min(ylims(:,1)), max(ylims(:,2))];
set(ax_handles, 'Ylim', ylim_new);

% Add main title
sgtitle('All Sessions Pupil Data');