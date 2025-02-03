function X = initial_glm(unit_data, unit_table)
%% Create simple models to examine what neurons are tuned for

% Choose the unit
unit_idx = 49;
data = unit_data(unit_idx);
unit_id = "Unit " + num2str(unit_table{unit_idx,1});

% 1. Create a table for the unit to run the model.

% a) Cue location: -4, -3, -2, -1, 0, 1, 2, 3, or 4
cue_loc = data.ids.sample_id;
valid_trials = ~isnan(cue_loc);
cue_loc = cue_loc(valid_trials);

% b) Hazard rate: 0.5 or -0.5
hazard = data.values.hazard(valid_trials);
hazard(hazard==0.05) = -0.5; % Center the variable

% c) Firing rate: baseline-subtract, z-scored firing rate over a given
% evoked window after cue onset
% i) Isolate evoked window of interest
sample_on_idx = round(data.times.sample_on*1000) + 1;
sample_on_idx = sample_on_idx(valid_trials);
window_size = 300;
end_idx = sample_on_idx + window_size - 1;
% ii) Subtract the baseline firing rate
evoked = squeeze(data.binned_spikes); % ms x all trials
evoked = evoked(:, valid_trials); % ms x valid trials
baseline = data.epochs.baseline(valid_trials);
baseline_subtracted = evoked - baseline;
baseline_subtracted = baseline_subtracted(sample_on_idx:end_idx, :);
% iii) Z-score (keep interpretation consistent)
mu = mean(baseline_subtracted, 1, "omitnan");
sigma = std(baseline_subtracted, 1, "omitnan");
z_scored = (baseline_subtracted - mu) ./ sigma;
% iv) Compute response
fr = mean(z_scored, 1, "omitnan")';

% iv) Combine predictors and response into design matrix
X = table(cue_loc, hazard, fr, 'VariableNames', {'cue_loc', 'hazard', 'fr'});

% 2. Run the model, saving results.


% 3. Repeat over a sliding window.
