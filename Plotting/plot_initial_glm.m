function plot_initial_glm(unit_table, u)
%% Plot a line graph for the different coefficients obtained from GLMs over
% different windows

data = unit_table(u, :);
results = data.coeffs{1, 1};
num_windows = numel(results);
step_size = 10; % Make argument if intending to modify
unit_id = "Unit " + data.unit_id;
filename = data.fileName{1, 1};
startIdx = strfind(filename, 'MM');
endIdx = strfind(filename, '.hdf5') - 1;
sessionName = filename(startIdx:endIdx);

% Initialize arrays to hold the coefficients for plotting
cue_loc_coeffs = nan(num_windows, 1);
hazard_coeffs = nan(num_windows, 1);
cue_hazard_coeffs = nan(num_windows, 1);
cue_loc_SEM = nan(num_windows, 1);
hazard_SEM = nan(num_windows, 1);
cue_hazard_SEM = nan(num_windows, 1);

% Get coefficients for each model/window
for i = 1:num_windows

    coeff_table = results{i};
    cue_loc_coeffs(i) = coeff_table.Estimate(2);
    hazard_coeffs(i) = coeff_table.Estimate(3);
    cue_hazard_coeffs(i) = coeff_table.Estimate(4);

    cue_loc_SEM(i) = coeff_table.SE(2);
    hazard_SEM(i) = coeff_table.SE(3);
    cue_hazard_SEM(i) = coeff_table.SE(4);

end

% Plot
fig = figure;
hold on;

% Plot each coefficient as a separate line
xaxis = (0:(num_windows - 1)) * step_size;
plot(xaxis, cue_loc_coeffs, 'b', 'DisplayName', 'cue loc', 'LineWidth', 2);
plot(xaxis, hazard_coeffs, 'r', 'DisplayName', 'hazard', 'LineWidth', 2);
plot(xaxis, cue_hazard_coeffs, 'm', 'DisplayName', 'cue loc:hazard', 'LineWidth', 2);

% Error bands
fill([xaxis, flip(xaxis)], ...
     [cue_loc_coeffs' + cue_loc_SEM', flip(cue_loc_coeffs' - cue_loc_SEM')], ...
     'b', 'FaceAlpha', 0.2, 'EdgeColor', 'none', 'HandleVisibility', 'off');
fill([xaxis, flip(xaxis)], ...
     [hazard_coeffs' + hazard_SEM', flip(hazard_coeffs' - hazard_SEM')], ...
     'r', 'FaceAlpha', 0.2, 'EdgeColor', 'none',  'HandleVisibility', 'off');
fill([xaxis, flip(xaxis)], ...
     [cue_hazard_coeffs' + cue_hazard_SEM', flip(cue_hazard_coeffs' - cue_hazard_SEM')], ...
     'm', 'FaceAlpha', 0.2, 'EdgeColor', 'none',  'HandleVisibility', 'off');

% Customize the plot
xlabel('Time from Cue Onset (ms)');
ylabel('Coefficient Value');
title({sessionName, unit_id}, 'Interpreter', 'none');
legend('show');
grid on;
hold off;

% Save as PDF
fig.Position = [82 167 1588 752];
pdfFileName = sessionName+"_"+unit_id+"_initial_glm.pdf";
exportgraphics(fig, pdfFileName, 'ContentType', 'vector');
close(fig);