function data = clean_spike(data, unit_id, start_code, end_code)
%% Adds cleaned data to the session's struct
% data: 1 x 1 struct with 8 fields for a session
% plot: boolean for whether or not to visualize cleaning process

% This is particular to the AODR protocol.
% There does not seem to be a fixation acquired code? So we must use sample
% on with an offset.
start_offset = -300; % ms to include before the start code.  
end_offset = 100; % ms to include after the end code.

% Default to not plotting
if nargin < 4
    will_plot = true;
end

% "For loops" are slow :)
% Technically the start code is relative to the fix on code. So if there
% are spikes recorded before the fix on code, are they negative? In other
% words, are spike times recorded relative to the fix on code or the trial
% start code?
% Yes, spike times are negative, so you don't need to include the trial
% start time
start_times = data.times.(start_code) + (start_offset/1000);
end_times = data.times.(end_code) + (end_offset/1000);

% Remove irrelevant units
relevant_unit = unit_id;
if isempty(relevant_unit)
    relevant_unit = data.spikes.id;
end
not_relevant_units = ~ismember(data.spikes.id',relevant_unit);
data.spikes.data(:,not_relevant_units) = [];
data.spikes.channel(not_relevant_units) = [];
data.spikes.id(not_relevant_units) = [];

%% 1) Arrange spike time data into a nan-buffed matrix (spike time matrix)
% neuron x spike_time x trials
n_units = length(data.spikes.id);
if n_units == 0
    warning('No units on the selected channel, exiting')
    return
end

%% Create matrix with dimension for spike times set to the max length,
% pre-filled with nans

% TO DO:
%%%%% NOTE THAT THE SPIKE DATA MATRIX IS NOT ALWAYS IN ORDER! YOU SHOULD
%%%%% ENSURE THAT THE UNIT ID MATCHES THE COLUMN OR THAT ALL OTHER SCRIPTS
%%%%% SELECT THE APPROPRIATE INDEX OF THE MATRIX THAT MATCHES THE UNIT ID!

n_trials = size(data.spikes.data,1);
data.spikes.data = table2cell(data.spikes.data);
all_max_spikes = cell2mat(cellfun(@(x) size(x,1),data.spikes.data,'UniformOutput',false));
max_spikes = max(all_max_spikes,[],"all");
data.spike_time_mat = nan(n_units,max_spikes,n_trials);

% select spikes within your start/end times
for u = 1:n_units
    for t = 1:n_trials
        tmp_spikes = data.spikes.data{t,u}(...
            data.spikes.data{t,u} >= start_times(t) &...
            data.spikes.data{t,u} <= end_times(t));
        data.spike_time_mat(u,1:length(tmp_spikes),t) = tmp_spikes - start_times(t); % recode spike times relative to new start time
    end
end

% Convert to ms
data.spike_time_mat = data.spike_time_mat*1000;

%% 2) Binned time course
max_time = round(max(data.spike_time_mat(:))); % What is the max spike time - round to nearest ms
spikes_idx = round(data.spike_time_mat); % spike times at closest ms
bin_width = 50; % ms width of bin (to average over)
kernel = ones(1,bin_width); % "boxcar" kernel
for u = 1:n_units
    for t = 1:n_trials
        spike_counts = histcounts(data.spike_time_mat(u,:,t),0:max_time); % bin spikes into ms bins
        % smooth using your bin window and assume ms sampling to get spikes
        % per second for each unit, trial, and time window
        data.binned_spikes(u,:,t) = movmean(spike_counts,bin_width).*1000;
        % data.binned_spikes(u,:,t) = convn(spike_counts,kernel,'same')./(bin_width/1000);
    end
end

% data.spikes = []; % save memory
end