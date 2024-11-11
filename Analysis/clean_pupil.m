function data = clean_pupil(data, start_code, end_code, will_plot)
%% Adds cleaned pupil diameter data to the session's struct
% data: 1 x 1 struct with 8 fields for a session
% plot: boolean for whether or not to visualize cleaning process

% This is particular to the AODR protocol.
% There does not seem to be a fixation acquired code? So we must use sample
% on with an offset.
start_offset = -300; % ms to include before the start code.
end_offset = 100; %ms to include after the end code.

% Default to not plotting
if nargin < 4
    will_plot = false;
end

%% 1) Create a trials x time matrix of pupil data.
% Get pupil response from when the animal fixates to when the animal makes
% a saccade for each trial.

% "For loops" are slow :)
% Get the index of the start time for each trial
start_idx = round(data.times.(start_code)*1000) + start_offset + 1; % The first element is time 0 so add 1
start_idx = start_idx(~isnan(data.times.(start_code)));
% Adjust for non-zero start time: assumes it is negative.
start_idx = start_idx + abs(data.times.('trial_start')*1000);
% Round to the nearest integer
start_idx = round(start_idx);

% Get the index of the end time for each trial
end_idx = round(data.times.(end_code)*1000) + end_offset + 1; % The first element is time 0 so add 1
end_idx = end_idx(~isnan(data.times.(end_code)));
% Adjust for non-zero start time
end_idx = end_idx + abs(data.times.('trial_start')*1000);
% Round to the nearest integer
end_idx = round(end_idx);

%% Get the pupil data from start code to end code for each trial
% Initialize trials x max saccade on time matrix of all NaNs
num_trials = data.header.validTrials;
max_tr_length = max(end_idx - start_idx) + 1;
pupil_data = nan(num_trials, max_tr_length);
for tr = 1:num_trials
    tr_pupil_data = data.signals.data(tr, 3);
    tr_pupil_data = tr_pupil_data{1};
    num_frames = size(tr_pupil_data,1);
    if start_idx(tr) < 1 || end_idx(tr) > num_frames
        continue % Skip trials without pupil data or invalid times
    end
    % Each pupil trace is aligned to start_offset ms before the
    % start_code and extends to the end_code
    pupil_data(tr, 1:(end_idx(tr) - start_idx(tr))+1) = tr_pupil_data(start_idx(tr):end_idx(tr));

    % Update all the signal data
    data.signals.data{tr,1} = data.signals.data{tr,1}(start_idx(tr):end_idx(tr));
    data.signals.data{tr,2} = data.signals.data{tr,2}(start_idx(tr):end_idx(tr));
    data.signals.data{tr,3} = data.signals.data{tr,3}(start_idx(tr):end_idx(tr));
end

%% 2) Z-score
% Z-score across all the pupil data, ignoring NaNs.
mu = nanmean(pupil_data(:));
sigma = nanstd(pupil_data(:));
z_scores = (pupil_data - mu) / sigma;

%% Plot to check that values
if will_plot
    figure;
    imagesc(z_scores);
    colorbar_handle = colorbar;
    title('Heatmap of Pupil Diameter Z-Scores');
    xlabel('Time (ms)');
    ylabel('Trials');
    ylabel(colorbar_handle, 'Z-Score');
    clim([-5 5]);
end

%% 3) Subtract the trial-averaged pupil trace
% Subtract out "noise" related to luminance and eye position that's
% consistent across trials.
avg_pupil_trace = nanmean(z_scores, 1);
standardized = z_scores - avg_pupil_trace;

%% 4) Smoothing
% Smooth using a boxcar filter with 151ms window.
% Define the boxcar filter parameters
bin_width = 151; % Window width in ms
kernel = ones(1, bin_width) / bin_width; % Boxcar kernel (normalized)

% Get the number of trials and time points
[num_trials, num_frames] = size(standardized);

% Initialize a matrix to hold the smoothed results
smoothed_data = nan(num_trials, num_frames); % Preallocate for NaNs

% Apply the smoothing to each trial (row)
for tr = 1:num_trials
    if any(~isnan(standardized(tr, :))) % Ensure there are non-NaN values
        smoothed_data(tr, :) = movmean(standardized(tr, :), bin_width);
    end
end
data.cleaned_pupil = smoothed_data; % Add to struct

%% Plot again to see why these steps are beneficial
if will_plot
    % Ask how many random trials the user wants to see
    num_plots = input('How many random trials do you want to check? ');
    to_plot = [100:100:800];
    for cur_plot = 1:num_plots
        % Choose a trial (row) at random
        rand_trial = to_plot(cur_plot); %randperm(num_trials, 1);
        while all(isnan(pupil_data(rand_trial, :))) || data.ids.score(rand_trial) < 0
            rand_trial = randperm(num_trials, 1);
        end
        original_trace = pupil_data(rand_trial, :);
        z_score_trace = z_scores(rand_trial, :);
        standardized_trace = standardized(rand_trial, :);
        smoothed_trace = smoothed_data(rand_trial, :);
        all_traces = [original_trace, z_score_trace, standardized_trace, smoothed_trace];
        y_min = min(all_traces, [], 'all');
        y_max = max(all_traces, [], 'all');
        y_limits = [y_min, y_max];
        figure;
        hold on;
        plot(original_trace, 'Color', [0 0.4470 0.7410], 'LineWidth', 1.5, 'DisplayName', 'Original', 'LineStyle', '-');
        plot(z_score_trace, 'Color', [0.8500 0.3250 0.0980], 'LineWidth', 1.5, 'DisplayName', 'Z-Scored', 'LineStyle', '--', 'LineWidth', 1.5);
        plot(standardized_trace, 'Color', [0.9290 0.6940 0.1250], 'LineWidth', 1.5, 'DisplayName', 'Standardized', 'LineStyle', ':');
        plot(smoothed_trace, 'Color', [0.4660 0.6740 0.1880], 'LineWidth', 2.5, 'DisplayName', 'Smoothed', 'LineStyle', '-');
        hold off;
        xlabel('Time (ms)');
        ylabel('Values');
        ylim(y_limits);
        grid on;
        legend('show');
        sgtitle(sprintf('Pupil Data Visualization (Trial %d)', rand_trial));
        sgtitle(sprintf('Pupil Data Cleaning (Trial %d)', rand_trial));
    end
end

%% 5) Get baseline pupil
% Average z-scored pupil diameter from 300ms prior to sample_on.
data.baseline_pupil = nanmean(data.cleaned_pupil(:, 1:abs(start_offset)),2);

%% 6) Get evoked pupil
%% Visualize pupil data to choose when to average over
window = 1000;
evoked_pupil = data.cleaned_pupil(:,abs(start_offset)+1:abs(start_offset)+window+1);
for tr = 1:num_trials
    data.evoked_max_pupil(tr) = max(nanrunmean(evoked_pupil(tr,:), 50));
    data.evoked_min_pupil(tr) = min(nanrunmean(evoked_pupil(tr,:), 50));
end

if will_plot
    % Choose a trial (row) at random
    num_plots = input('How many random trials do you want to check? ');
    for cur_plot = 1:num_plots
        rand_trial = randperm(num_trials, 1);
        while all(isnan(pupil_data(rand_trial, :))) || data.ids.score(rand_trial) < 0
            rand_trial = randperm(num_trials, 1);
        end
        figure;
        hold on;
        plot(evoked_pupil(rand_trial, :), 'b-', 'LineWidth', 2);
        xlabel('Time (ms)');
        ylabel('Evoked Pupil Diameter')
        title(['Trial ', num2str(rand_trial)]);
        grid on;
        hold off;
    end
end
data.bs_evoked_pupil = evoked_pupil - data.baseline_pupil;

end