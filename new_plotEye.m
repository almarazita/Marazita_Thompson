function new_plotEye(data, byTrial)
% Plot the position and diameter of the pupil during each trial
% data is a 1 x 1 struct for a single session

% Set byTrial to false by default (plot all trials together)
arguments
    data = []
    byTrial logical = false
end

% Get the name of the session
filename = data.data.header.filename;
startIdx = strfind(filename, 'MM');
endIdx = strfind(filename, '.hdf5') - 1;
sessionName = filename(startIdx:endIdx);

% Declare variables that will be re-used
y_labs = ["Horizontal Position (dva)" "Vertical Position (dva)" "Diameter (au)"];
if byTrial
    event_labs = ["Fixation On", "Sample On", "Fixation Off", "Saccade On", "All Off"];
    cols = [9, 19, 8, 18, 4];
    event_idxs = zeros(1,4);
end

% For each trial
% numTrials = length(data(1).analog.data); % Both units have the same analog data, so pull from the first row
numTrials = data.data.header.numTrials;
for tr=300:301 % Change
    
    % Color-code line by trial type
    if data.data.values.hazard(tr) == 0.05
        color = "b";
    elseif data.data.values.hazard(tr) == 0.50
        color = "r";
    else
        color = "k";
    end

    % If plotting trial-by-trial
    if byTrial

        % Create a new figure for each trial 
        figure;

        % Calculate indexes for trial events
        event_idxs = arrayfun(@(x) new_getEventIndex(data, tr, x), cols);

    end

    % For each measurement
    for col=1:3
    
        % Create a panel and plot the data
        subplot(3,1,col);
        cur_eye_data = data.data.signals.data(tr,col);
        cur_eye_data = cur_eye_data{1};
        plot(cur_eye_data, "Color", color, "LineWidth", 0.1);

        % Add labels
        xlabel("Time (ms)")
        ylabel(y_labs(col))

        % Keep the current figure or not
        if ~byTrial
            hold on;
        else
            % Add vertical lines indicating trial events
            xline(event_idxs, '--', event_labs)
        end
        
    end

    % Add title if plotting trial-by-trial
    if byTrial
        sgtitle({sessionName+" Eye Data", "Trial "+tr}, 'Interpreter', 'none')
    end

end

% Add title
if ~byTrial
    sgtitle(sessionName+" Eye Data", 'Interpreter', 'none')
end
end

% Helper function that returns the appropriate location to index into
% analog data for trial events
function idx = new_getEventIndex(data, tr, col)
% data is a 1 x 1 struct for a single session from plotEye
% tr is the trial number (row in the timing table)
% col is the column in the timing table corresponding to the desired trial
% event
    
    % Get start time for this trial
    start_time = data.data.times.trial_start(tr);
     % Convert to ms?
    start_time = start_time*1000;
    %start_time = data.data.times.trial_begin(tr);

    % Extract event time from table
    idx = data.data.times(tr, col);
    % Convert to double in ms
    idx = idx{1,1}*1000;
    % The first element is time 0
    idx = idx + 1;
    % Adjust for non-zero start time
    idx = idx + abs(start_time);
    % Round to the nearest integer
    idx = round(idx);

end