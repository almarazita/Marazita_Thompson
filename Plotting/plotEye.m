function plotEye(data, byTrial)
% Plot the position and diameter of the pupil during each trial
% data: a 1 x 1 struct for a single session

% Set byTrial to false by default (plot all trials together)
arguments
    data = []
    byTrial logical = false
end

% Get the name of the session
filename = data.header.filename;
startIdx = strfind(filename, 'MM');
endIdx = strfind(filename, '.hdf5') - 1;
sessionName = filename(startIdx:endIdx);

% Declare variables that will be re-used
y_labs = ["Horizontal Position (dva)" "Vertical Position (dva)" "Diameter (au)"];
if byTrial
    event_labs = ["Fixation On", "Sample On", "Fixation Off", "Saccade On", "All Off"];
    cols = [9, 19, 8, 18, 4];
end

% For each trial
%numTrials = data.header.validTrials;
for tr=242:242 % Change
    
    % Color-code line by trial type
    if data.values.hazard(tr) == 0.05
        color = [4 94 167]./255;
    elseif data.values.hazard(tr) == 0.50
        color = [194 0 77]./255;
    else
        color = "k";
    end

    % If plotting trial-by-trial
    if byTrial

        % Create a new figure for each trial 
        figure;

        % Calculate indexes for trial events
        event_idxs = arrayfun(@(x) getEventIndex(data, tr, x), cols);

    end

    % For each measurement
    for col=1:3
    
        % Create a panel and plot the data
        subplot(3,1,col);
        cur_eye_data = data.signals.data(tr,col);
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
        true_tr = data.values.trial_num(tr);
        sgtitle({sessionName+" Eye Data", "Trial "+true_tr}, 'Interpreter', 'none')
    end

end

% Add title
if ~byTrial
    sgtitle(sessionName+" Eye Data", 'Interpreter', 'none')
end
end