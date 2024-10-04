%% Check sample_on times summary statistics

num_sessions = length(all_pyr_cleaned_data);

means = zeros(1, num_sessions);
medians = zeros(1, num_sessions);
stds = zeros(1, num_sessions);
vars = zeros(1, num_sessions);
mins = zeros(1, num_sessions);
maxs = zeros(1, num_sessions);

for i = 1:num_sessions

    % Check variation in time window averaged over for baseline
    cur_session = all_pyr_cleaned_data{i};
    sample_on_times = cur_session.times.sample_on * 1000;
    means(i) = nanmean(sample_on_times);
    medians(i) = nanmedian(sample_on_times);
    stds(i) = nanstd(sample_on_times);
    vars(i) = var(sample_on_times, 'omitnan');
    mins(i) = min(sample_on_times, [], 'omitnan');
    maxs(i) = max(sample_on_times, [], 'omitnan');

end

summaryStats = table((1:num_sessions)', means', medians', stds', vars',...
    mins', maxs', 'VariableNames', {'SessionNumber', 'Mean', 'Median',...
    'StdDev', 'Variance', 'Min', 'Max'});