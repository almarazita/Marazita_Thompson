%% 1) Create a trials x time matrix of pupil data.
% Get pupil response from when the animal fixates to when the animal makes
% a saccade for each trial.

% Confirm that the first timepoint is the same as fixation on
if sum(data.times.fp_on) ~= 0
    disp(['Trials are not aligned to fixation on. Quitting.'])
    return
end

% Get the index of the saccade start time for each trial
num_trials = data.header.numTrials;
sac_on_idxs = nan(numTrials, 1);
for tr = 1:num_trials
    sac_on_idxs(tr) = new_getEventIndex(data, tr, 18); % sac_on = column 18
end

% Get the pupil data from fixation on to saccade on for each trial
% Initialize trials x max saccade on time matrix of all NaNs
max_tr_length = max(sac_on_idxs);
pupil_data = nan(num_trials, max_tr_length);
for tr = 1:num_trials
    sac_on_idx = sac_on_idxs(tr);
    if ~isnan(sac_on_idx) % Skip trials without a sac_on time
        tr_pupil_data = data.signals.data(tr, 3);
        tr_pupil_data = tr_pupil_data{1};
        num_frames = size(tr_pupil_data,1);
        if sac_on_idx < 1 || sac_on_idx > num_frames
            continue % Skip trials without pupil data or invalid sac_on times
        end
        pupil_data(tr, 1:sac_on_idx) = tr_pupil_data(1:sac_on_idx);
    end
end

%% 2) Z-score
% Z-score across all the pupil data, ignoring NaNs.
mu = nanmean(pupil_data(:));
sigma = nanstd(pupil_data(:));
z_scores = (pupil_data - mu) / sigma;

%% Plot to check that values are between -4 and +4.
figure;
imagesc(z_scores);
colorbar_handle = colorbar;
title('Heatmap of Pupil Diameter Z-Scores');
xlabel('Time (ms)');
ylabel('Trials');
ylabel(colorbar_handle, 'Z-Score');
clim([-5 5]);

%% 3) Subtract the trial-averaged pupil trace
% Subtract out "noise" related to luminance and eye position that's
% consistent across trials.
avg_pupil_trace = nanmean(z_scores, 1);
standardized = z_scores - avg_pupil_trace;

%% 3) Smoothing (ChatGPT)
% Smooth using a boxcar filter with 151ms window.
% Define the boxcar filter parameters
bin_width = 151; % Window width in ms
kernel = ones(1, bin_width); % Boxcar kernel (not normalized)

% Get the number of trials and time points
[num_trials, num_frames] = size(standardized);

% Initialize a matrix to hold the smoothed results
smoothed_data = nan(num_trials, num_frames); % Preallocate for NaNs

% Apply the smoothing to each trial (row)
for tr = 1:num_trials
    if any(~isnan(standardized(tr, :))) % Ensure there are non-NaN values
        smoothed_data(tr, :) = conv(standardized(tr, :), ...
            kernel / bin_width, 'same');
    end
end

%% Plot again to see why these steps are beneficial.
% Choose a trial (row) at random
rand_trial = randperm(num_trials, 1);
while all(isnan(pupil_data(rand_trial, :)))
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

% Average z-scored pupil diameter from fix_on to sample_on (~200-300 ms) to
% get a single dot for each trial.

% Plot baseline diameter as a function as the time that the trial started.

% Plot the pupil data for a given session or neuron to look at hazard 1 vs.
% 2.

% Extract evoked, which is sample_on out to ~500-900 ms, but look at raw
% data and pupil constriction seeming to go away or go back to some steady
% value.