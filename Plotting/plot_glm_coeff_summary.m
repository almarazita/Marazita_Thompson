%% Plot initial GLM distribution of significant time windows

window_size = 150;
step_size = 10;
num_windows = 3;
num_units = size(unit_table, 1);
alpha = 0.05;

sig_cue = zeros(num_windows, 1);
sig_hazard = zeros(num_windows, 1);
sig_cue_hazard = zeros(num_windows, 1);

for u = 1:num_units

    data = unit_table(u, :);
    results = data.coeffs{1, 1};
    
    cue_loc_ps = nan(num_windows, 1);
    hazard_ps = nan(num_windows, 1);
    cue_hazard_ps = nan(num_windows, 1);
    
    % Get coefficients, SE, and p-value for each model/window
    for i = 1:num_windows
    
        coeff_table = results{i};
    
        cue_loc_ps(i) = coeff_table.pValue(2);
        hazard_ps(i) = coeff_table.pValue(3);
        cue_hazard_ps(i) = coeff_table.pValue(4);
    
    end
    
    % Determine which are significant
    is_significant_cue = cue_loc_ps < alpha;
    is_significant_hazard = hazard_ps < alpha;
    is_significant_cue_hazard = cue_hazard_ps < alpha;
    
    % Add to population count
    sig_cue = sig_cue + is_significant_cue;
    sig_hazard = sig_hazard + is_significant_hazard;
    sig_cue_hazard = sig_cue_hazard + is_significant_cue_hazard;

end

% Compute the X axis
xaxis = (0:(num_windows - 1)) * step_size;

% Create figure
figure;

% Plot the histogram for cue location significance (Blue)
subplot(3, 1, 1); % First subplot for sig_cue
bar(xaxis, sig_cue, 'FaceColor', 'b', 'EdgeColor', 'b', 'FaceAlpha', 0.7);
xlabel('Time from Cue Onset (ms)');
ylabel('Neurons with Significant Coefficient');
title('Cue Location');
xlim([0 max(xaxis)]); % Set X axis limits
ylim([0 num_units]);
grid on;

% Plot the histogram for hazard significance (Red)
subplot(3, 1, 2); % Second subplot for sig_hazard
bar(xaxis, sig_hazard, 'FaceColor', 'r', 'EdgeColor', 'r', 'FaceAlpha', 0.7);
xlabel('Time from Cue Onset (ms)');
ylabel('Neurons with Significant Coefficient');
title('Hazard');
xlim([0 max(xaxis)]); % Set X axis limits
ylim([0 num_units]);
grid on;

% Plot the histogram for cue-location-hazard significance (Magenta)
subplot(3, 1, 3); % Third subplot for sig_cue_hazard
bar(xaxis, sig_cue_hazard, 'FaceColor', 'm', 'EdgeColor', 'm', 'FaceAlpha', 0.7);
xlabel('Time from Cue Onset (ms)');
ylabel('Neurons with Significant Coefficient');
title('Cue Location: Hazard');
xlim([0 max(xaxis)]); % Set X axis limits
ylim([0 num_units]);
grid on;