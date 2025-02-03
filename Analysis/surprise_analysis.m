function p = surprise_analysis(unit_data, unit_table)
%% Neuron summary by "surprise"
% Plot the firing rate distributions of a neuron for trials with evidence
% that signals switching behavior under both conditions. Do not inclue the
% center cue location, and create a single bar plot by outcome,
% proximal/distal, and hazard rate.
% Assumes you have unit_data and unit_table loaded in
% u: row/struct of unit data table to use

num_units = length(unit_data);
for u=1:num_units

    %% 1. Identify trials of interest.
    % - Weak switch cue (two middle positions)
    data = unit_data(u);
    unit_id = "Unit " + num2str(unit_table{u,1});
    
    % Criterion 1: Weak switch cue
    % What the previous correct target and hazard rate were
    prevState = [nan; data.ids.correct_target(1:end-1)];
    prevH = [nan; data.values.hazard(1:end-1)];
    thisH = data.values.hazard;
    cue_loc = data.ids.sample_id;
    switch_cue = zeros(length(cue_loc),1);
    stay_cue = zeros(length(cue_loc),1);
    
    % The cue signals switch if its position is away from what was previously
    % correct, and we're in the same AODR block
    switch_cue(thisH==prevH & prevState==1 & ismember(cue_loc,[2,3,4]))=1; % Bottom to top
    switch_cue(thisH==prevH & prevState==2 & ismember(cue_loc,[-2,-3,-4]))=1; % Top to bottom
    stay_cue(thisH==prevH & prevState==1 & ismember(cue_loc,[-2,-3,-4]))=1; % Bottom before, bottom now
    stay_cue(thisH==prevH & prevState==2 & ismember(cue_loc,[2,3,4]))=1; % Top before, top now

    % Criterion 2: Switch rate
    low_switch = 0.05;
    high_switch = 0.50;
    
    % Criterion 3: Whether there was a switch
    obj_switch = zeros(length(cue_loc),1);
    obj_switch(prevState~=data.ids.correct_target)=1;
    obj_switch(1) = 0; % No objective switch on first trial but will return true otherwise

    % Criterion 4: Response
    correct = data.ids.score==1 & ~isnan(data.ids.choice); % "Incorrect" here does not correspond to all trials where monkey wasn't correct since that includes saccade errors. 
    incorrect = data.ids.score==0 & ~isnan(data.ids.choice); % Make sure not including other trials.

    % We collapse over whether the cue itself was "proximal or distal"
    % because for "extreme" cue locations this is not applicable.
    correct_struct(u).switch.low = data.epochs.target_on(data.values.hazard==low_switch & switch_cue & obj_switch & correct);
    correct_struct(u).stay.low = data.epochs.target_on(data.values.hazard==low_switch & stay_cue & ~obj_switch & correct);
    incorrect_struct(u).switch.low = data.epochs.target_on(data.values.hazard==low_switch & stay_cue & ~obj_switch & incorrect);
    incorrect_struct(u).stay.low = data.epochs.target_on(data.values.hazard==low_switch & switch_cue & obj_switch & incorrect);

    correct_struct(u).switch.high = data.epochs.target_on(data.values.hazard==high_switch & switch_cue & obj_switch & correct);
    correct_struct(u).stay.high = data.epochs.target_on(data.values.hazard==high_switch & stay_cue & ~obj_switch & correct);
    incorrect_struct(u).switch.high = data.epochs.target_on(data.values.hazard==high_switch & stay_cue & ~obj_switch & incorrect);
    incorrect_struct(u).stay.high = data.epochs.target_on(data.values.hazard==high_switch & switch_cue & obj_switch & incorrect);
    
    % Let's examine the distributions
    % figure; hold on;
    % histogram(correct_struct(u).switch.low,'BinWidth',5,'FaceColor','g');
    % histogram(correct_struct(u).stay.low,'BinWidth',5,'FaceColor','y');
    
    if sum(~isnan(correct_struct(u).switch.low)) == 0 || sum(~isnan(correct_struct(u).stay.low)) == 0
        p(u) = NaN;
    else
        p(u) = ranksum(correct_struct(u).switch.low, correct_struct(u).stay.low);
    end

    % Create the bar plot with error bars
    % figure; hold on;
    % avgs = [low_stay_avg', low_surprise_avg', high_stay_avg', high_surprise_avg'];
    % b = bar(avgs, 'EdgeColor', 'none');
    % b(1).FaceColor = 'w';
    % b(1).EdgeColor = [4 94 167] / 255;
    % b(2).FaceColor = [4 94 167] / 255;
    % b(3).FaceColor = 'w';
    % b(3).EdgeColor = [194 0 77] / 255;
    % b(4).FaceColor = [194 0 77] / 255;
    % 
    % % Add SEM as error bars
    % ngroups = 4;
    % nbars = 4;
    % err = [low_stay_SEM', low_surprise_SEM', high_stay_SEM', high_surprise_SEM'];
    % groupwidth = min(0.8, nbars/(nbars + 1.5));
    % for i = 1:nbars
    %     x = (1:ngroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*nbars);
    %     errorbar(x, avgs(:,i), err(:,i), 'k', 'LineStyle', 'none');
    % end
    % hold off
    % 
    % % Customize x-tick labels
    % xticks(1:4);
    % xticklabels({'Incorrect Stay', 'Correct Switch', 'Correct Stay', 'Incorrect Switch'});
    % xtickangle(45);
    % 
    % % Set axis labels
    % xlabel('Outcome');
    % ylabel('Firing Rate');
    % 
    % % Legend
    % b(1).DisplayName = 'Low H Proximal';
    % b(2).DisplayName = 'Low H Distal';
    % b(3).DisplayName = 'High H Proximal';
    % b(4).DisplayName = 'High H Distal';
    % legend(b, 'Location', 'north');
    % 
    % % Title
    % filename = data.fileName;
    % startIdx = strfind(filename, 'MM');
    % endIdx = strfind(filename, '.hdf5') - 1;
    % sessionName = filename(startIdx:endIdx);
    % sgtitle({sessionName, unit_id}, 'Interpreter', 'none')
    % 
    % hold off;

    %% Optionally, save as PDF
    % fig.Position = [82 167 1588 752];
    % pdfFileName = sessionName+"_"+unit_id+"_surprise_summary.pdf";
    % exportgraphics(fig, pdfFileName, 'ContentType', 'vector');
    % close(fig);

end
end