function plot_initial_glm(unit_table, u)
%% Plot a line graph for the different coefficients obtained from GLMs over
% different windows. Works with initial_glm 3-predictor model.

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
choice_coeffs = nan(num_windows, 1);
cue_hazard_coeffs = nan(num_windows, 1);
cue_h_choice_coeffs = nan(num_windows, 1);

cue_loc_SEM = nan(num_windows, 1);
hazard_SEM = nan(num_windows, 1);
choice_SEM = nan(num_windows, 1);
cue_hazard_SEM = nan(num_windows, 1);
cue_h_choice_SEM = nan(num_windows, 1);

cue_loc_ps = nan(num_windows, 1);
hazard_ps = nan(num_windows, 1);
choice_ps = nan(num_windows, 1);
cue_hazard_ps = nan(num_windows, 1);
cue_h_choice_ps = nan(num_windows, 1);

% Get coefficients, SE, and p-value for each model/window
for i = 1:num_windows

    coeff_table = results{i};

    cue_loc_coeffs(i) = coeff_table.Estimate(2);
    hazard_coeffs(i) = coeff_table.Estimate(3);
    choice_coeffs(i) = coeff_table.Estimate(4);
    cue_hazard_coeffs(i) = coeff_table.Estimate(5);
    cue_h_choice_coeffs(i) = coeff_table.Estimate(8);

    cue_loc_SEM(i) = coeff_table.SE(2);
    hazard_SEM(i) = coeff_table.SE(3);
    choice_SEM(i) = coeff_table.SE(4);
    cue_hazard_SEM(i) = coeff_table.SE(5);
    cue_h_choice_SEM(i) = coeff_table.SE(8);

    cue_loc_ps(i) = coeff_table.pValue(2);
    hazard_ps(i) = coeff_table.pValue(3);
    choice_ps(i) = coeff_table.Estimate(4);
    cue_hazard_ps(i) = coeff_table.pValue(5);
    cue_h_choice_ps(i) = coeff_table.pValue(8);

end

% Determine which are significant
alpha = 0.05;
is_significant_cue_loc = cue_loc_ps < alpha;
is_significant_hazard = hazard_ps < alpha;
is_significant_choice = choice_ps < alpha;
is_significant_cue_hazard = cue_hazard_ps < alpha;
is_significant_cue_h_choice = cue_h_choice_ps < alpha;

% Plot
fig = figure;
hold on;

% Plot each coefficient as a separate line
xaxis = (0:(num_windows - 1)) * step_size;
plot(xaxis, cue_loc_coeffs, 'b', 'DisplayName', 'cue loc', 'LineWidth', 2);
plot(xaxis, hazard_coeffs, 'r', 'DisplayName', 'hazard', 'LineWidth', 2);
plot(xaxis, choice_coeffs, 'g', 'DisplayName', 'choice', 'LineWidth', 2);
plot(xaxis, cue_hazard_coeffs, 'm', 'DisplayName', 'cue loc:hazard', 'LineWidth', 2);
plot(xaxis, cue_h_choice_coeffs, 'c', 'DisplayName', 'cue loc:hazard:choice', 'LineWidth', 2);

% Error bands
fill([xaxis, flip(xaxis)], ...
     [cue_loc_coeffs' + cue_loc_SEM', flip(cue_loc_coeffs' - cue_loc_SEM')], ...
     'b', 'FaceAlpha', 0.2, 'EdgeColor', 'none', 'HandleVisibility', 'off');
fill([xaxis, flip(xaxis)], ...
     [hazard_coeffs' + hazard_SEM', flip(hazard_coeffs' - hazard_SEM')], ...
     'r', 'FaceAlpha', 0.2, 'EdgeColor', 'none',  'HandleVisibility', 'off');
fill([xaxis, flip(xaxis)], ...
     [choice_coeffs' + hazard_SEM', flip(choice_coeffs' - choice_SEM')], ...
     'g', 'FaceAlpha', 0.2, 'EdgeColor', 'none',  'HandleVisibility', 'off');
fill([xaxis, flip(xaxis)], ...
     [cue_hazard_coeffs' + cue_hazard_SEM', flip(cue_hazard_coeffs' - cue_hazard_SEM')], ...
     'm', 'FaceAlpha', 0.2, 'EdgeColor', 'none',  'HandleVisibility', 'off');
fill([xaxis, flip(xaxis)], ...
     [cue_h_choice_coeffs' + cue_h_choice_SEM', flip(cue_h_choice_coeffs' - cue_h_choice_SEM')], ...
     'c', 'FaceAlpha', 0.2, 'EdgeColor', 'none',  'HandleVisibility', 'off');

% Plot small asterisks for significant coefficients
sig_height = max(max([cue_loc_coeffs, hazard_coeffs, choice_coeffs, cue_hazard_coeffs, cue_h_choice_coeffs])) + 0.05;
sig_heights = [sig_height * 0.90, sig_height * 0.95, sig_height, sig_height * 1.05, sig_height * 1.1];
for i = 1:num_windows
    if is_significant_cue_loc(i)
        text(xaxis(i), sig_heights(1), '*', 'Color', 'b', 'FontSize', 12, 'HorizontalAlignment', 'center');
    end
    if is_significant_hazard(i)
        text(xaxis(i), sig_heights(2), '*', 'Color', 'r', 'FontSize', 12, 'HorizontalAlignment', 'center');
    end
    if is_significant_choice(i)
        text(xaxis(i), sig_heights(3), '*', 'Color', 'g', 'FontSize', 12, 'HorizontalAlignment', 'center');
    end
    if is_significant_cue_hazard(i)
        text(xaxis(i), sig_heights(4), '*', 'Color', 'm', 'FontSize', 12, 'HorizontalAlignment', 'center');
    end
    if is_significant_cue_h_choice(i)
        text(xaxis(i), sig_heights(5), '*', 'Color', 'c', 'FontSize', 12, 'HorizontalAlignment', 'center');
    end
end

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