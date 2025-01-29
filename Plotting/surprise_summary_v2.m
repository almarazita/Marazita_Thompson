function surprise_summary_v2(unit_data, unit_table)
%% Neuron summary by "surprise"
% Plot the firing rate distributions of a neuron for trials with evidence
% that signals switching behavior under both conditions. Do not inclue the
% center cue location, and create a single bar plot by outcome,
% proximal/distal, and hazard rate.
% Assumes you have unit_data and unit_table loaded in
% u: row/struct of unit data table to use

num_plots = length(unit_data);
for u=1:num_plots

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
    % The cue signals switch if its position is away from what was previously
    % correct, and we're in the same AODR block
    switch_cue(thisH==prevH & prevState==1 & cue_loc==1)=1; % Bottom to top
    switch_cue(thisH==prevH & prevState==2 & cue_loc==-1)=1; % Top to bottom
    
    % Criterion 2: Switch rate
    low_switch = 0.05;
    high_switch = 0.50;
    
    % Criterion 3: Whether there was a switch
    obj_switch = zeros(length(cue_loc),1);
    obj_switch(prevState~=data.ids.correct_target)=1;
    
    % Criterion 4: Response
    correct = data.ids.score==1 & ~isnan(data.ids.choice);
    
    %% 2. Cue location tuning curve
    fig = figure('Position', [100, 100, 800, 600]);
    axs = [subplot(1, 2, 1), subplot(1, 2, 2)];
    plotHazardCueAvgFR(data,1,axs);
    cla;
    title('');
    
    %% 3. By outcome, hazard rate, and proximity (surprise/stay)
    % i) Low switch
    % a) Surprising (weak switch) cues
    % - Incorrect stay
    %disp("Low Switch")
    incorrect_stay = data.values.hazard==low_switch & switch_cue & obj_switch & ~correct;
    %disp("Incorrect stays: " + num2str(sum(incorrect_stay)))
    % - Correct switch
    correct_switch = data.values.hazard==low_switch & switch_cue & obj_switch & correct;
    %disp("Correct switches: " + num2str(sum(correct_switch)))
    % - Correct stay
    correct_stay = data.values.hazard==low_switch & switch_cue & ~obj_switch & correct;
    %disp("Correct stays: " + num2str(sum(correct_stay)))
    % - Incorrect switch
    incorrect_switch = data.values.hazard==low_switch & switch_cue & ~obj_switch & ~correct;
    %disp("Incorrect switches: " + num2str(sum(incorrect_switch)))

    low_surprise_avg = [mean(data.epochs.target_on(incorrect_stay)),...
        mean(data.epochs.target_on(correct_switch)),...
        mean(data.epochs.target_on(correct_stay)),...
        mean(data.epochs.target_on(incorrect_switch))];
    low_surprise_SEM = [std(data.epochs.target_on(incorrect_stay))/sqrt(length(data.epochs.target_on(incorrect_stay))),...
        mean(data.epochs.target_on(correct_switch))/sqrt(length(data.epochs.target_on(correct_switch))),...
        mean(data.epochs.target_on(correct_stay))/sqrt(length(data.epochs.target_on(correct_stay))),...
        mean(data.epochs.target_on(incorrect_switch))/sqrt(length(data.epochs.target_on(incorrect_switch)))];

    % b) Weak stay cues
    % - Incorrect stay
    %disp("Low Switch")
    incorrect_stay = data.values.hazard==low_switch & ~switch_cue & obj_switch & ~correct;
    %disp("Incorrect stays: " + num2str(sum(incorrect_stay)))
    % - Correct switch
    correct_switch = data.values.hazard==low_switch & ~switch_cue & obj_switch & correct;
    %disp("Correct switches: " + num2str(sum(correct_switch)))
    % - Correct stay
    correct_stay = data.values.hazard==low_switch & ~switch_cue & ~obj_switch & correct;
    %disp("Correct stays: " + num2str(sum(correct_stay)))
    % - Incorrect switch
    incorrect_switch = data.values.hazard==low_switch & ~switch_cue & ~obj_switch & ~correct;
    %disp("Incorrect switches: " + num2str(sum(incorrect_switch)))

    low_stay_avg = [mean(data.epochs.target_on(incorrect_stay)),...
        mean(data.epochs.target_on(correct_switch)),...
        mean(data.epochs.target_on(correct_stay)),...
        mean(data.epochs.target_on(incorrect_switch))];
    low_stay_SEM = [std(data.epochs.target_on(incorrect_stay))/sqrt(length(data.epochs.target_on(incorrect_stay))),...
        mean(data.epochs.target_on(correct_switch))/sqrt(length(data.epochs.target_on(correct_switch))),...
        mean(data.epochs.target_on(correct_stay))/sqrt(length(data.epochs.target_on(correct_stay))),...
        mean(data.epochs.target_on(incorrect_switch))/sqrt(length(data.epochs.target_on(incorrect_switch)))];

    % ii) High switch
    %disp("High Switch")
    % a) Surprising (weak switch) cues
    % - Incorrect stay
    incorrect_stay = data.values.hazard==high_switch & switch_cue & obj_switch & ~correct;
    %disp("Incorrect stays: " + num2str(sum(incorrect_stay)))
    % - Correct switch
    correct_switch = data.values.hazard==high_switch & switch_cue & obj_switch & correct;
    %disp("Correct switches: " + num2str(sum(correct_switch)))
    % - Correct stay
    correct_stay = data.values.hazard==high_switch & switch_cue & ~obj_switch & correct;
    %disp("Correct stays: " + num2str(sum(correct_stay)))
    % - Incorrect switch
    incorrect_switch = data.values.hazard==high_switch & switch_cue & ~obj_switch & ~correct;
    %disp("Incorrect switches: " + num2str(sum(incorrect_switch)))

    high_surprise_avg = [mean(data.epochs.target_on(incorrect_stay)),...
        mean(data.epochs.target_on(correct_switch)),...
        mean(data.epochs.target_on(correct_stay)),...
        mean(data.epochs.target_on(incorrect_switch))];
    high_surprise_SEM = [std(data.epochs.target_on(incorrect_stay))/sqrt(length(data.epochs.target_on(incorrect_stay))),...
        mean(data.epochs.target_on(correct_switch))/sqrt(length(data.epochs.target_on(correct_switch))),...
        mean(data.epochs.target_on(correct_stay))/sqrt(length(data.epochs.target_on(correct_stay))),...
        mean(data.epochs.target_on(incorrect_switch))/sqrt(length(data.epochs.target_on(incorrect_switch)))];

    % b) Weak stay cues
    % - Incorrect stay
    incorrect_stay = data.values.hazard==high_switch & ~switch_cue & obj_switch & ~correct;
    %disp("Incorrect stays: " + num2str(sum(incorrect_stay)))
    % - Correct switch
    correct_switch = data.values.hazard==high_switch & ~switch_cue & obj_switch & correct;
    %disp("Correct switches: " + num2str(sum(correct_switch)))
    % - Correct stay
    correct_stay = data.values.hazard==high_switch & ~switch_cue & ~obj_switch & correct;
    %disp("Correct stays: " + num2str(sum(correct_stay)))
    % - Incorrect switch
    incorrect_switch = data.values.hazard==high_switch & ~switch_cue & ~obj_switch & ~correct;
    %disp("Incorrect switches: " + num2str(sum(incorrect_switch)))

    high_stay_avg = [mean(data.epochs.target_on(incorrect_stay)),...
        mean(data.epochs.target_on(correct_switch)),...
        mean(data.epochs.target_on(correct_stay)),...
        mean(data.epochs.target_on(incorrect_switch))];
    high_stay_SEM = [std(data.epochs.target_on(incorrect_stay))/sqrt(length(data.epochs.target_on(incorrect_stay))),...
        mean(data.epochs.target_on(correct_switch))/sqrt(length(data.epochs.target_on(correct_switch))),...
        mean(data.epochs.target_on(correct_stay))/sqrt(length(data.epochs.target_on(correct_stay))),...
        mean(data.epochs.target_on(incorrect_switch))/sqrt(length(data.epochs.target_on(incorrect_switch)))];

    % Create the bar plot with error bars
    subplot(1, 2, 2);
    hold on;
    avgs = [low_stay_avg', low_surprise_avg', high_stay_avg', high_surprise_avg'];
    b = bar(avgs, 'EdgeColor', 'none');
    b(1).FaceColor = 'w';
    b(1).EdgeColor = [4 94 167] / 255;
    b(2).FaceColor = [4 94 167] / 255;
    b(3).FaceColor = 'w';
    b(3).EdgeColor = [194 0 77] / 255;
    b(4).FaceColor = [194 0 77] / 255;

    % Add SEM as error bars
    ngroups = 4;
    nbars = 4;
    err = [low_stay_SEM', low_surprise_SEM', high_stay_SEM', high_surprise_SEM'];
    groupwidth = min(0.8, nbars/(nbars + 1.5));
    for i = 1:nbars
        x = (1:ngroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*nbars);
        errorbar(x, avgs(:,i), err(:,i), 'k', 'LineStyle', 'none');
    end
    hold off

    % Customize x-tick labels
    xticks(1:4);
    xticklabels({'Incorrect Stay', 'Correct Switch', 'Correct Stay', 'Incorrect Switch'});
    xtickangle(45);

    % Set axis labels
    xlabel('Outcome');
    ylabel('Firing Rate');

    % Legend
    b(1).DisplayName = 'Low H Proximal';
    b(2).DisplayName = 'Low H Distal';
    b(3).DisplayName = 'High H Proximal';
    b(4).DisplayName = 'High H Distal';
    legend(b, 'Location', 'north');

    % Title
    filename = data.fileName;
    startIdx = strfind(filename, 'MM');
    endIdx = strfind(filename, '.hdf5') - 1;
    sessionName = filename(startIdx:endIdx);
    sgtitle({sessionName, unit_id}, 'Interpreter', 'none')

    hold off;

    %% Optionally, save as PDF
    fig.Position = [82 167 1588 752];
    pdfFileName = sessionName+"_"+unit_id+"_surprise_summary.pdf";
    exportgraphics(fig, pdfFileName, 'ContentType', 'vector');
    close(fig);

end
end