function new_plotEye(data, byTrial)
% Plot the position and diameter of the pupil during each trial
% data is a 1 x 1 struct for a single session

% Set byTrial to false by default (plot all trials together)
arguments
    data = []
    byTrial logical = false
end

% Get the name of the session
filename = data.header.filename;
startIdx = strfind(filename, 'Anubis');
endIdx = strfind(filename, '.hdf5') - 1;
sessionName = filename(startIdx:endIdx);

% Declare variables that will be re-used
y_labs = ["Horizontal Position (dva)" "Vertical Position (dva)" "Diameter (au)"];
if byTrial
<<<<<<< Updated upstream:new_plotEye.m
    event_labs = ["Fixation On", "Sample On", "Fixation Off", "Saccade On", "All Off"];
    cols = [9, 19, 8, 18, 4];
    event_idxs = zeros(1,4);
end

% For each trial
% numTrials = length(data(1).analog.data); % Both units have the same analog data, so pull from the first row
numTrials = data.header.numTrials;
for tr=894:895 % Change
=======
    event_labs = ["Fixation Acq", "Sample On", "Fixation Off", "Saccade On", "All Off"];
    cols = [5, 8, 11, 10, 4];
end

% For each trial
numTrials = data.header.validTrials;
for tr=1:numTrials % Change
>>>>>>> Stashed changes:Plotting/plotEye.m
    
    % Color-code line by trial type
    if data.values.hazard(tr) == 0.05
        color = "b";
    elseif data.values.hazard(tr) == 0.50
        color = "r";
    else
        color = "k";
    end

    % If plotting trial-by-trial
    if byTrial

        % Create a new figure for each trial 
        % figure;

        % Calculate indexes for trial events
        event_idxs = arrayfun(@(x) new_getEventIndex(data, tr, x), cols);

    end

    % For each measurement
    for col=1:3
    
        % Create a panel and plot the data
        subplot(3,1,col);
        if col == 3
            cur_eye_data = data.cleaned_pupil(tr,:);
        else
            cur_eye_data = data.signals.data(tr,col);
            cur_eye_data = cur_eye_data{1};
        end
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