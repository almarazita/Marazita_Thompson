function data = new_extractAODR_sessionNeural(fileName, monkey, unit_id)

% ecode names are:
%   trial_num, task_id, hazard, correct_target, sample_id, score,
%   choice, RT, sac_endx, sac_endy, t1_x, t1_y, t2_x, t2_y, sample_x,
%   sample_y, session, tacp, llr_for_switch, choice_switch,
%   previous_reward, correct_shown

start_code = 'sample_on';
end_code = 'sac_on';

%% Get the data
[data, obj] = goldLabDataSession.convertSession( ...
    fileName, ...
    'tag',          'AODR', ...
    'monkey',       monkey, ...
    'sortType',     'Sorted', ...
    'converter',    'Pyramid', ...
    'convertSpecs', 'AODR_experiment');

%% Set and get valid trials here, so that you don't have trials with
% just nan's.
valid = ~isnan(data.times.(start_code)) & ~isnan(data.times.(end_code));

% Remove invalid trials
data.header.validTrials = sum(valid); % Add but keep original number for reference
data.ids = data.ids(valid,:);
data.times = data.times(valid,:);
data.values = data.values(valid,:);
data.signals.data = data.signals.data(valid,:);
data.spikes.data = data.spikes.data(valid,:);

%% Clean spike data
data = clean_spike(data, unit_id, start_code, end_code);

%% Clean pupil data
% TO DO: Does clean pupil remove data.signals for memory?
data = clean_pupil(data, start_code, end_code);

%% Update times
% So the times need to be updated if we want to use existing scripts
no_change = {'trial_begin','trial_end', 'trial_wrt', 'fp_on'}; % These values are either global clock times and/or don't need to change
vars_change = ~ismember(data.times.Properties.VariableNames, no_change); % get all columns that need to be changed
time_diff = data.times.sample_on(:) - 0.3; % in sec, we have aligned all trials to 300 ms before sample on.
data.times(:,vars_change) = data.times(:,vars_change) - time_diff;
data.times.trial_start = data.times.fp_on; % the start time will now be 0 (first index), since the true start time has been cut off
data.values.saccades_t_start = data.values.saccades_t_start - time_diff;
data.values.saccades_t_end = data.values.saccades_t_end - time_diff;
data.values.all_saccades_t_start = data.values.all_saccades_t_start - time_diff;
data.values.all_saccades_t_end = data.values.all_saccades_t_end - time_diff;

end