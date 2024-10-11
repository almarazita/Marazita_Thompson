function data = new_extractAODR_sessionNeural(fileName, monkey, unit_id)

    % ecode names are:
    %   trial_num, task_id, hazard, correct_target, sample_id, score, 
    %   choice, RT, sac_endx, sac_endy, t1_x, t1_y, t2_x, t2_y, sample_x, 
    %   sample_y, session, tacp, llr_for_switch, choice_switch, 
    %   previous_reward, correct_shown
    
    % Get the data
    [data, obj] = goldLabDataSession.convertSession( ...
        fileName, ...
        'tag',          'AODR', ...
        'monkey',       monkey, ...
        'sortType',     'Sorted', ...
        'converter',    'Pyramid', ...
        'convertSpecs', 'AODR_experiment');
    
    % At this point, we do not filter specific neurons of interest so that it is
    % easy to explore the results of a session (e.g., when sorting units initially)
    
    %% Arrange spike time data into a nan-buffed matrix (spike time matrix)
    % neuron x spike_time x trials
    relevant_unit = unit_id;
    if isempty(relevant_unit)
        relevant_unit = data.spikes.id;
    end
    not_relevant_units = ~ismember(data.spikes.id',relevant_unit);
    data.spikes.data(:,not_relevant_units) = [];
    data.spikes.channel(not_relevant_units) = [];
    data.spikes.id(not_relevant_units) = [];
    
    n_units = length(data.spikes.id);
    if n_units == 0
        warning('No units on the selected channel, exiting')
        return
    end
    
    % Create matrix with dimension for spike times set to the max length,
    % pre-filled with nans
    n_trials = size(data.spikes.data,1);
    data.spikes.data = table2cell(data.spikes.data);
    all_max_spikes = cell2mat(cellfun(@(x) size(x,1),data.spikes.data,'UniformOutput',false));
    max_spikes = max(all_max_spikes,[],"all");
    data.spike_time_mat = nan(n_units,max_spikes,n_trials);
    
    for u = 1:n_units
        for t = 1:n_trials
            data.spike_time_mat(u,1:length(data.spikes.data{t,u}),t) = data.spikes.data{t,u};
        end
    end
    
    % Convert to ms
    data.spike_time_mat = data.spike_time_mat*1000;
    
    %% Binned time course
    max_time = round(max(data.spike_time_mat(:))); % What is the max spike time - round to nearest ms
    spikes_idx = round(data.spike_time_mat); % spike times at closest ms
    bin_width = 50; % ms width of bin (to average over)
    kernel = ones(1,bin_width); % "boxcar" kernel
    for u = 1:n_units
        for t = 1:n_trials
            spike_counts = histcounts(data.spike_time_mat(u,:,t),0:max_time); % bin spikes into ms bins
            % smooth using your bin window and assume ms sampling to get spikes
            % per second for each unit, trial, and time window
            data.binned_spikes(u,:,t) = convn(spike_counts,kernel,'same')./(bin_width/1000); 
        end
    end

    %% Clean pupil data
    data = clean_pupil(data);
    
end