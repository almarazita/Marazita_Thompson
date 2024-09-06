function idx = new_getEventIndex(data, tr, col)
% Returns the appropriate location to index into analog data for trial
% events
% data is a 1 x 1 struct for a single session from plotEye
% tr is the trial number (row in the timing table)
% col is the column in the timing table corresponding to the desired trial
% event
    
    % Get start time for this trial
    start_time = data.data.times.trial_start(tr);

    % Extract event time from table
    idx = data.data.times(tr, col);
    % The first element is time 0
    idx = idx + 1;
    % Adjust for non-zero start time
    idx = idx + abs(start_time);
    % Round to the nearest integer
    idx = round(idx);
    % Convert to double
    idx = table2array(idx);

end