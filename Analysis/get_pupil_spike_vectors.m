function results = get_pupil_spike_vectors(all_sessions, method)
%% Returns baseline and evoked pupil and firing rate data for each session
%  to use for correlation analyses
%  all_sessions is the 94 x 1 cell array all_pyr_cleaned_data returned by
%  loadClean

% Select method for computing evoked pupil response
valid_methods = ["bs", "change", "resid"];
if isempty(method) || ~ismember(method, valid_methods)
    method = "bs";
end

% Initialize variables
num_sessions = length(all_sessions);

all_baseline_pupil = cell(num_sessions, 1);
all_residual_baseline_pupil = cell(num_sessions, 1);
all_evoked_pupil = cell(num_sessions, 1);

all_baseline_fr = cell(num_sessions, 1);
all_residual_baseline_fr = cell(num_sessions, 1);
all_bs_evoked_fr = cell(num_sessions, 1);

overall_unit = 1;
% For each session
for i = 1:num_sessions
    % Get data
    cur_session = all_sessions{i};

    mdl_baseline_pupil = fitlm(cur_session.times.trial_begin, cur_session.baseline_pupil);
    residuals_baseline_pupil = mdl_baseline_pupil.Residuals.Raw;

    % Initialize variables
    num_trials = cur_session.header.validTrials;
    unit_ids = cur_session.spikes.id;
    num_units = length(unit_ids);
    baseline_fr = nan(num_trials, num_units);
    baseline_fr_resid = nan(num_trials, num_units);
    evoked_fr = nan(num_trials, num_units);
    % For each unit
    for u = 1:num_units
        % Get its data
        unit_spikes = squeeze(cur_session.binned_spikes(u,:,:)); % ms x trials
        % Baseline = average firing rate 300ms before sample_on
        baseline_fr(:, u) = mean(unit_spikes(1:300, :), 1);
        % Evoked = average firing rate 300ms after sample_on
        evoked_fr(:, u) = mean(unit_spikes(300:600, :), 1);

        % Compute residuals
        mdl_baseline_fr = fitlm(cur_session.times.trial_begin, baseline_fr(:, u));
        residuals_baseline_fr = mdl_baseline_fr.Residuals.Raw;
        baseline_fr_resid(:, u) = residuals_baseline_fr;

        overall_unit = overall_unit + 1; % Increment
    end

    % Add this session's baseline and evoked pupil/firing rates to cell
    % arrays
    all_baseline_pupil{i} = cur_session.baseline_pupil;
    all_residual_baseline_pupil{i} = residuals_baseline_pupil;
    if method == "bs"
        all_evoked_pupil{i} = cur_session.evoked_max_pupil' - cur_session.baseline_pupil;
    end

    all_baseline_fr{i} = baseline_fr;
    all_residual_baseline_fr{i} = baseline_fr_resid;
    all_bs_evoked_fr{i} = evoked_fr - baseline_fr;

end

% Pupil change method returns a cell array for all sessions
if method == "change"
    all_evoked_pupil = get_pupil_change(all_sessions);
end
if method == "resid"
    all_evoked_pupil = get_pupil_resid(all_sessions);
end

% Compile data into single struct to return
results = struct();

results.all_baseline_pupil = all_baseline_pupil;
results.all_residual_baseline_pupil = all_residual_baseline_pupil;
results.all_evoked_pupil = all_evoked_pupil;

results.all_baseline_fr = all_baseline_fr;
results.all_residual_baseline_fr = all_residual_baseline_fr;
results.all_bs_evoked_fr = all_bs_evoked_fr;