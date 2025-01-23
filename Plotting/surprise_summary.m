%% Neuron summary by "surprise"
% Plot the firing rate distributions of a neuron for trials with evidence
% that signals switching behavior under both conditions.

%% 1. Identify trials of interest.
% - Weak switch cue (middle three positions)
data = unit_data(96);

% Criterion 1: Weak switch cue
% What the previous correct target and hazard rate were
prevState = [nan; data.ids.correct_target(1:end-1)];
prevH = [nan; data.values.hazard(1:end-1)];
thisH = data.values.hazard;
cue_loc = data.ids.sample_id;
switch_cue = zeros(length(cue_loc),1);
% The cue signals switch if its position is away from what was previously
% correct, and we're in the same AODR block
switch_cue(thisH==prevH & prevState==1 & (cue_loc==0 | cue_loc==1))=1; % Bottom to top
switch_cue(thisH==prevH & prevState==2 & (cue_loc==0 | cue_loc==-1))=1; % Top to bottom

% Criterion 2: Switch rate
low_switch = 0.05;
high_switch = 0.50;

% Criterion 3: Whether there was a switch
obj_switch = zeros(length(cue_loc),1);
obj_switch(prevState~=data.ids.correct_target)=1;

% Criterion 4: Response
correct = data.ids.score==1 & ~isnan(data.ids.choice);

%% 2. Compute.
% Isolate trials
% By response
% - Incorrect stay
incorrect_stay = data.values.hazard==low_switch & switch_cue & obj_switch & ~correct;
disp("Incorrect stays: " + num2str(sum(incorrect_stay)))
% - Correct switch
correct_switch = data.values.hazard==low_switch & switch_cue & obj_switch & correct;
disp("Correct switches: " + num2str(sum(correct_switch)))
% - Correct stay
correct_stay = data.values.hazard==low_switch & switch_cue & ~obj_switch & correct;
disp("Correct stays: " + num2str(sum(correct_stay)))
% - Incorrect switch
incorrect_switch = data.values.hazard==low_switch & switch_cue & ~obj_switch & ~correct;
disp("Incorrect switches: " + num2str(sum(incorrect_switch)))

low_h_avg = [mean(data.epochs.target_on(incorrect_stay)),...
    mean(data.epochs.target_on(correct_switch)),...
    mean(data.epochs.target_on(correct_stay)),...
    mean(data.epochs.target_on(incorrect_switch))];
low_h_SEM = [std(data.epochs.target_on(incorrect_stay))/sqrt(length(data.epochs.target_on(incorrect_stay))),...
    mean(data.epochs.target_on(correct_switch))/sqrt(length(data.epochs.target_on(correct_switch))),...
    mean(data.epochs.target_on(correct_stay))/sqrt(length(data.epochs.target_on(correct_stay))),...
    mean(data.epochs.target_on(incorrect_switch))/sqrt(length(data.epochs.target_on(incorrect_switch)))];

incorrect_stay = data.values.hazard==high_switch & switch_cue & obj_switch & ~correct;
disp("Incorrect stays: " + num2str(sum(incorrect_stay)))
% - Correct switch
correct_switch = data.values.hazard==high_switch & switch_cue & obj_switch & correct;
disp("Correct switches: " + num2str(sum(correct_switch)))
% - Correct stay
correct_stay = data.values.hazard==high_switch & switch_cue & ~obj_switch & correct;
disp("Correct stays: " + num2str(sum(correct_stay)))
% - Incorrect switch
incorrect_switch = data.values.hazard==high_switch & switch_cue & ~obj_switch & ~correct;
disp("Incorrect switches: " + num2str(sum(incorrect_switch)))

high_h_avg = [mean(data.epochs.target_on(incorrect_stay)),...
    mean(data.epochs.target_on(correct_switch)),...
    mean(data.epochs.target_on(correct_stay)),...
    mean(data.epochs.target_on(incorrect_switch))];
high_h_SEM = [std(data.epochs.target_on(incorrect_stay))/sqrt(length(data.epochs.target_on(incorrect_stay))),...
    mean(data.epochs.target_on(correct_switch))/sqrt(length(data.epochs.target_on(correct_switch))),...
    mean(data.epochs.target_on(correct_stay))/sqrt(length(data.epochs.target_on(correct_stay))),...
    mean(data.epochs.target_on(incorrect_switch))/sqrt(length(data.epochs.target_on(incorrect_switch)))];

%% 3. Plot.
% Create the bar plot with error bars
figure;
hold on;
b = bar([low_h_avg', high_h_avg'], 'EdgeColor', 'none');
b(1).FaceColor = [4 94 167] / 255;
b(2).FaceColor = [194 0 77] / 255;

% Add SEM as error bars
%errorbar(1:4, low_h_avg, low_h_SEM, 'k', 'LineStyle', 'none', 'LineWidth', 1);
%errorbar(1:4 + 0.4, high_h_avg, high_h_SEM, 'k', 'LineStyle', 'none', 'LineWidth', 1);

% Customize x-tick labels
xticks(1:4);
xticklabels({'Incorrect Stay', 'Correct Switch', 'Correct Stay', 'Incorrect Switch'});
xtickangle(45);

% Set axis labels
ylabel('Firing Rate');

hold off;

%% By cue location
% Low switch
bottom = data.values.hazard==low_switch & switch_cue & cue_loc==-1;
disp("Bottom: " + num2str(sum(bottom)))
middle = data.values.hazard==low_switch & switch_cue & cue_loc==0;
disp("Middle: " + num2str(sum(middle)))
top = data.values.hazard==low_switch & switch_cue & cue_loc==1;
disp("Top: " + num2str(sum(top)))

low_h_avg = [mean(data.epochs.target_on(bottom)),...
    mean(data.epochs.target_on(middle)),...
    mean(data.epochs.target_on(top))];
low_h_SEM = [std(data.epochs.target_on(bottom))/sqrt(length(data.epochs.target_on(bottom))),...
    std(data.epochs.target_on(middle))/sqrt(length(data.epochs.target_on(middle))),...
    std(data.epochs.target_on(top))/sqrt(length(data.epochs.target_on(top)))];

% High switch
bottom = data.values.hazard==high_switch & switch_cue & cue_loc==-1;
disp("Bottom: " + num2str(sum(bottom)))
middle = data.values.hazard==high_switch & switch_cue & cue_loc==0;
disp("Middle: " + num2str(sum(middle)))
top = data.values.hazard==high_switch & switch_cue & cue_loc==1;
disp("Top: " + num2str(sum(top)))

high_h_avg = [mean(data.epochs.target_on(bottom)),...
    mean(data.epochs.target_on(middle)),...
    mean(data.epochs.target_on(top))];
high_h_SEM = [std(data.epochs.target_on(bottom))/sqrt(length(data.epochs.target_on(bottom))),...
    std(data.epochs.target_on(middle))/sqrt(length(data.epochs.target_on(middle))),...
    std(data.epochs.target_on(top))/sqrt(length(data.epochs.target_on(top)))];

%% Plot
figure;
hold on;
b = bar([low_h_avg', high_h_avg'], 'EdgeColor', 'none');
b(1).FaceColor = [4 94 167] / 255;
b(2).FaceColor = [194 0 77] / 255;

% Add SEM as error bars
%errorbar(low_h_avg, low_h_SEM, 'k', 'LineStyle', 'none', 'LineWidth', 1);

% Customize x-tick labels
xticks(1:4);
xticklabels({'Weak T1', 'Ambiguous', 'Weak T2'});
xtickangle(45);

% Set axis labels
ylabel('Firing Rate');

hold off;

% 2. Compute average firing rate for each group of trials.
% 3. Create bar plots, one for each condition.
% Check how many trials are in each condition, see what's possible to
% average over.

