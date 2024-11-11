function all_evoked_pupil = get_pupil_resid(all_pyr_cleaned_data)
%% Use residuals from the regression against baseline to compute the evoked pupil response.

num_sessions = length(all_pyr_cleaned_data);
all_evoked_pupil = cell(num_sessions, 1);

for i = 1:num_sessions
    cur_session = all_pyr_cleaned_data{i};

    mdl = fitlm(cur_session.baseline_pupil, cur_session.bs_evoked_pupil);
    residuals = mdl.Residuals.Raw;

    all_evoked_pupil{i} = residuals;
end