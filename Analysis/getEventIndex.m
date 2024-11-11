% Helper function that returns the appropriate location to index into
% analog data for trial events
function idx = getEventIndex(data, tr, col)
% data: a 1 x 1 struct for a single session from plotEye
% tr: the trial number (row in the timing table)
% col: the column in the timing table corresponding to the desired trial
% event
    
    % Get start time for this trial
    start_time = data.times.trial_start(tr);
     % Convert to ms
    start_time = start_time*1000;

    % Extract event time from table
    idx = data.times(tr, col);
    % Convert to double in ms
    idx = idx{1,1}*1000;
    % The first element is time 0
    idx = idx + 1;
    % Adjust for non-zero start time
    idx = idx + abs(start_time);
    % Round to the nearest integer
    idx = round(idx);

end