%% Plot full GLM distribution of coefficients

% Setup
num_units = size(unit_table, 1);
num_epochs = 3;
alpha = 0.05;

cue_loc_coeffs = nan(num_units, num_epochs);
hazard_coeffs = nan(num_units, num_epochs);
choice_coeffs = nan(num_units, num_epochs);
cue_hazard_coeffs = nan(num_units, num_epochs);
cue_h_choice_coeffs = nan(num_units, num_epochs);

cue_loc_ps = nan(num_units, num_epochs);
hazard_ps = nan(num_units, num_epochs);
choice_ps = nan(num_units, num_epochs);
cue_hazard_ps = nan(num_units, num_epochs);
cue_h_choice_ps = nan(num_units, num_epochs);

for u = 1:num_units

    data = unit_table(u, :);
    results = data.coeffs{1, 1};

    for epoch_num = 1:num_epochs

        coeff_table = results{epoch_num};

        cue_loc_coeffs(u, epoch_num) = coeff_table.Estimate(2);
        hazard_coeffs(u, epoch_num) = coeff_table.Estimate(3);
        cue_hazard_coeffs(u, epoch_num) = coeff_table.Estimate(4);
        % choice_coeffs(u, epoch_num) = coeff_table.Estimate(4);
        % cue_hazard_coeffs(u, epoch_num) = coeff_table.Estimate(5);
        % cue_h_choice_coeffs(u, epoch_num) = coeff_table.Estimate(8);

        cue_loc_ps(u, epoch_num) = coeff_table.pValue(2);
        hazard_ps(u, epoch_num) = coeff_table.pValue(3);
        cue_hazard_ps(u, epoch_num) = coeff_table.pValue(4);
        % choice_ps(u, epoch_num) = coeff_table.Estimate(4);
        % cue_hazard_ps(u, epoch_num) = coeff_table.pValue(5);
        % cue_h_choice_ps(u, epoch_num) = coeff_table.pValue(8);

    end

end

epoch_names = ["Visual Epoch", "Memory Epoch", "Saccade Epoch"];
for epoch_num = 1:num_epochs

    % Create a new figure for the current epoch
    figure;

    % Define common bins
    edges = linspace(min([cue_loc_coeffs(:, epoch_num); hazard_coeffs(:, epoch_num); choice_coeffs(:, epoch_num); ...
                          cue_hazard_coeffs(:, epoch_num); cue_h_choice_coeffs(:, epoch_num)]), ...
                     max([cue_loc_coeffs(:, epoch_num); hazard_coeffs(:, epoch_num); choice_coeffs(:, epoch_num); ...
                          cue_hazard_coeffs(:, epoch_num); cue_h_choice_coeffs(:, epoch_num)]), 20); % 20 bins
    
    % Create a 2x3 grid of subplots
    % Each subplot will correspond to a different coefficient for the current epoch

    % Subplot 1: Histogram for cue location coefficients
    % subplot(2, 3, 1);
    subplot(1, 3, 1);
    sig_loc = cue_loc_ps(:, epoch_num) < alpha;
    histogram(cue_loc_coeffs(:, epoch_num), 'BinEdges', edges, 'FaceColor', 'w', 'EdgeColor', 'k');
    hold on;
    histogram(cue_loc_coeffs(sig_loc, epoch_num), 'BinEdges', edges, 'FaceColor', 'b', 'EdgeColor', 'k');
    xline(0, 'k--', 'LineWidth', 1);
    title('Cue Location');
    xlabel('Coefficient Value');
    ylabel('Number of Neurons');
    ylim([0 num_units]);
    grid on;

    % Subplot 2: Histogram for hazard coefficients
    % subplot(2, 3, 2);
    subplot(1, 3, 2);
    sig_loc = hazard_ps(:, epoch_num) < alpha;
    histogram(hazard_coeffs(:, epoch_num), 'BinEdges', edges, 'FaceColor', 'w', 'EdgeColor', 'k');
    hold on;
    histogram(hazard_coeffs(sig_loc, epoch_num), 'BinEdges', edges, 'FaceColor', 'r', 'EdgeColor', 'k');
    xline(0, 'k--', 'LineWidth', 1);
    title('Hazard');
    xlabel('Coefficient Value');
    ylabel('Number of Neurons');
    ylim([0 num_units]);
    grid on;

    % Subplot 3: Histogram for choice coefficients
    % subplot(2, 3, 3);
    % sig_loc = choice_ps(:, epoch_num) < alpha;
    % histogram(choice_coeffs(:, epoch_num), 'BinEdges', edges, 'FaceColor', 'w', 'EdgeColor', 'k');
    % hold on;
    % histogram(choice_coeffs(sig_loc, epoch_num), 'BinEdges', edges, 'FaceColor', 'g', 'EdgeColor', 'k');
    % xline(0, 'k--', 'LineWidth', 1);
    % title('Choice');
    % xlabel('Coefficient Value');
    % ylabel('Number of Neurons');
    % ylim([0 num_units]);
    % grid on;

    % Subplot 4: Histogram for cue-hazard coefficients
    % subplot(2, 3, 4);
    subplot(1, 3, 3);
    sig_loc = cue_hazard_ps(:, epoch_num) < alpha;
    histogram(cue_hazard_coeffs(:, epoch_num), 'BinEdges', edges, 'FaceColor', 'w', 'EdgeColor', 'k');
    hold on;
    histogram(cue_hazard_coeffs(sig_loc, epoch_num), 'BinEdges', edges, 'FaceColor', 'm', 'EdgeColor', 'k');
    xline(0, 'k--', 'LineWidth', 1);
    title('Cue-Hazard');
    xlabel('Coefficient Value');
    ylabel('Number of Neurons');
    ylim([0 num_units]);
    grid on;

    % Subplot 5: Histogram for cue-hazard-choice coefficients
    % subplot(2, 3, 5);
    % sig_loc = cue_h_choice_ps(:, epoch_num) < alpha;
    % histogram(cue_h_choice_coeffs(:, epoch_num), 'BinEdges', edges, 'FaceColor', 'w', 'EdgeColor', 'k');
    % hold on;
    % histogram(cue_h_choice_coeffs(sig_loc, epoch_num), 'BinEdges', edges, 'FaceColor', 'c', 'EdgeColor', 'k');
    % xline(0, 'k--', 'LineWidth', 1);
    % title('Cue-Hazard-Choice');
    % xlabel('Coefficient Value');
    % ylabel('Number of Neurons');
    % ylim([0 num_units]);
    % grid on;
    
    % Add a common title for the figure
    sgtitle(epoch_names(epoch_num));

end