for u = 1:size(unit_table,1)
    %% First do this for low hazard
    criteria = epoched_data(u).values.hazard == 0.05 & ~isnan(epoched_data(u).ids.sample_id) & epoched_data(u).ids.score==1;

    trial_FR = epoched_data(u).epochs.target_on(criteria)';
    
    epoched_data(u).values.llr_for_switch(epoched_data(u).values.llr_for_switch == -inf) = -1;
    epoched_data(u).values.llr_for_switch(epoched_data(u).values.llr_for_switch == inf) = 1;
    trial_llr = epoched_data(u).values.llr_for_switch(criteria);
    llr_vals = nonanunique(epoched_data(u).values.llr_for_switch);
    max_trials = max(histcounts(trial_llr));
    LLR_mat = nan(max_trials,length(llr_vals));
    for v = 1:length(llr_vals)
        fr = trial_FR(trial_llr == llr_vals(v));
        LLR_mat(1:length(fr),v) = fr;
    end
    unit_table.lowH_FR_by_llr(u,:) = nanmean(LLR_mat,1);

    %% Second do this for high hazard
    criteria = epoched_data(u).values.hazard == 0.5 & ~isnan(epoched_data(u).ids.sample_id) & epoched_data(u).ids.score==1;

    trial_FR = epoched_data(u).epochs.target_on(criteria)';
    
    epoched_data(u).values.llr_for_switch(epoched_data(u).values.llr_for_switch == -inf) = -1;
    epoched_data(u).values.llr_for_switch(epoched_data(u).values.llr_for_switch == inf) = 1;
    trial_llr = epoched_data(u).values.llr_for_switch(criteria);
    llr_vals = nonanunique(epoched_data(u).values.llr_for_switch);
    max_trials = max(histcounts(trial_llr));
    LLR_mat = nan(max_trials,length(llr_vals));
    for v = 1:length(llr_vals)
        fr = trial_FR(trial_llr == llr_vals(v));
        LLR_mat(1:length(fr),v) = fr;
    end
    unit_table.highH_FR_by_llr(u,:) = nanmean(LLR_mat,1);
end
%% Plot summary
criteria = unit_table.visual_evoked_p<0.05;
figure;
subplot(2,1,1);
violinplot(unit_table.highH_FR_by_llr(criteria,:))
subplot(2,1,2);
violinplot(unit_table.lowH_FR_by_llr(criteria,:))