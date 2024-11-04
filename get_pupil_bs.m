%function get_pupil_bs(all_pyr_cleaned_data)
%% Use baseline subtraction to compute the evoked pupil response.

num_sessions = length(all_pyr_cleaned_data);
all_betas = cell(num_sessions, 1);
for i = 1:num_sessions

    % Get session and its number of trials
    cur_session = all_pyr_cleaned_data{i};
    num_trials = cur_session.header.numTrials;
    
    % Calculate evoked pupil in a 200ms sliding window starting at sample_on
    evoked_pupil = cell(num_trials, 1);
    window_size = 200;
    step_size = 10;
    % For each trial
    for tr = 1:num_trials
        % Get cue and saccade onset times
        sample_on_idx = new_getEventIndex(cur_session, tr, 19); % sample_on = column 19
        sac_on_idx = new_getEventIndex(cur_session, tr, 18); % sac_on = column 18
    
        % Only continue for valid trials
        if ~isnan(sample_on_idx) && ~isnan(cur_session.ids.choice(tr)) % Will change after cleaning
            % Define the start times for each 200ms window through the delay period
            max_start = sac_on_idx - window_size;
            window_starts = sample_on_idx:step_size:max_start;
        
            % Create an array for the current trial's evoked values
            num_windows = length(window_starts);
            tr_evoked_pupil = nan(1, num_windows);
            
            for window_num = 1:num_windows
                window_start = window_starts(window_num);
                window_end = window_start + window_size;
                tr_evoked_pupil(window_num) = max(nanrunmean(cur_session.cleaned_pupil(tr, window_start:window_end), 50));
            end
        
            % Add this trial's evoked pupil to cell array for this session
            evoked_pupil{tr} = tr_evoked_pupil - cur_session.baseline_pupil(tr);
        end
    end
    
    %% Calculate regression slope
    % Convert to matrix
    lens = cellfun(@length, evoked_pupil);
    nonzero_lens = lens(lens > 0);
    max_common_windows = min(nonzero_lens); % Include only windows that exist for all valid trials
    evoked_pupil_mat = nan(num_trials, max_common_windows);
    for tr = 1:num_trials
        cur_evokeds = evoked_pupil{tr};
        if ~isempty(cur_evokeds)
            evoked_pupil_mat(tr, :) = cur_evokeds(1:max_common_windows);
        end
    end
    
    % Get pupil-pupil linear regression slope for each evoked window
    betas = nan(max_common_windows, 1);
    for window = 1:max_common_windows
        evoked = evoked_pupil_mat(:, window);
        mdl = fitlm(cur_session.baseline_pupil, evoked);
        betas(window) = mdl.Coefficients.Estimate(2);
    end
    all_betas{i} = betas;
    
    %% Plot
    figure;
    xaxis = (0:(max_common_windows - 1)) * 10;
    plot(xaxis, betas, 'LineWidth', 2);
    xlabel('Time from Cue Onset (ms)');
    ylabel('Pupil-Pupil Beta');
    filename = cur_session.header.filename;
    startIdx = strfind(filename, 'MM');
    endIdx = strfind(filename, '.hdf5') - 1;
    sessionName = filename(startIdx:endIdx);
    sgtitle(sessionName, 'Interpreter', 'none')

    fprintf('Session %d is done.\n', i);
end

% Convert to matrix
lens = cellfun(@length, all_betas);
nonzero_lens = lens(lens > 0);
max_common_windows = min(nonzero_lens); % Include only windows that exist for all valid trials
all_betas_mat = nan(num_sessions, max_common_windows);
for i = 1:num_sessions
    cur_betas = all_betas{i};
    if ~isempty(cur_betas)
        all_betas_mat(i, :) = cur_betas(1:max_common_windows);
    end
end

% Calculate and plot average betas across sessions
avg_betas = mean(all_betas_mat, 1);
sem_betas = std(all_betas_mat, 0, 1) ./ sqrt(size(all_betas_mat, 1));
xaxis = (0:(max_common_windows - 1)) * 10;
figure;
hold on;
upper = avg_betas + sem_betas;
lower = avg_betas - sem_betas;
fill([xaxis xaxis(end:-1:1)], [upper lower(end:-1:1)],...
    [0.5 0.5 0.5], 'EdgeColor', 'none', 'FaceAlpha', 0.3);
plot(xaxis, avg_betas, 'k', 'LineWidth', 2);
xlabel('Time from Cue Onset (ms)');
ylabel('Pupil-Pupil Beta');