function raster(session)

% session is a struct
spike_times = session.spike_time_mat; % 1 x 326 x trials

figure;
num_time_steps = size(spike_times, 2);
num_trials = size(spike_times, 3);
for trial = 1:num_trials
    yaxis = ones(1, num_time_steps)*trial;
    scatter(spike_times(2,:,trial), yaxis, 1, 'k');
    hold on;
end

% figure;
% binned_spikes = session.data.binned_spikes; % 1 x bins x trials
% avg_binned_spikes = mean(binned_spikes, 2); % 1 x trials
% for trial = 1:num_trials
%     scatter(trial, avg_binned_spikes(trial), 'k');
%     hold on;
% end

end