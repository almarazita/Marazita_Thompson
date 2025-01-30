function epochs = epochData(data,unit_idx,baseline_sub)
%% function [data] = epochData(data,unit_idx,baseline_sub)
% epochs data from AODR task based on multiple event combinations.
% base_line sub indicates whether the epoched data should be baseline
% subtracted or not. I believe you can use either "session" data where the
% binned spikes matrix contains multiple units in the frist dimension, 
% or "unit" data where the the first dim has been squeezed out.

valid = ~isnan(data.times.('sample_on')) & ~isnan(data.times.('sac_on'));
tmp = data;
tmp.binned_spikes = tmp.binned_spikes(unit_idx,:,valid); % unit x ms x trial
tmp.baseline_pupil = tmp.baseline_pupil(valid,:);
tmp.bs_evoked_pupil = tmp.bs_evoked_pupil(valid,:);
tmp.cleaned_pupil = tmp.cleaned_pupil(valid,:);
tmp.ids = tmp.ids(valid,:);
tmp.times = tmp.times(valid,:);
tmp.values = tmp.values(valid,:);
tmp.spikes = []; % for memory
tmp.spike_time_mat = [];
tmp.signals = [];

% Calculate baseline -- very important for comapring between tasks that are
% blocked in case you want to subtract
% Gives mean baseline for each trial 300ms prior to sample on.
epochs.baseline(unit_idx,:) = plotBaselineDrift_AODR(tmp,1,'sample_on',300,[],0);

if baseline_sub
    epochs.is_bs = 1; % is baseline subtracted
    tmp.binned_spikes(unit_idx,:,:) = squeeze(tmp.binned_spikes(unit_idx,:,:)) - squeeze(epochs.baseline(unit_idx,:));
else
    epochs.is_bs = 0;
end

% This will give +- window_width/2 around the event of interest
window_width = [0, 300];

% Get mean target-on activity for 300 ms after target onset for
% each trial
[~,target_on] = plotPSTHAligned(tmp,'sample_on',window_width,[],[],0,0);
event_idx = ~isnan(tmp.times.('sample_on'));
epochs.target_on(unit_idx,event_idx) = mean(target_on,'omitnan');

% Get mean saccade-on activity for 300 ms prior to onset for
% each trial
window_width = [300, 0];
[~,saccade_on] = plotPSTHAligned(tmp,'sac_on',window_width,[],[],0,0);
event_idx = ~isnan(tmp.times.('sac_on'));
epochs.saccade_on(unit_idx,event_idx) = mean(saccade_on,'omitnan');

% Get mean memory-related activity:
% From the time that the target (cue) has turned off, there is
% about 1000 ms until the animal can make the decision (fix off)
% The visual period is 300 ms after target on. The cue is 50 ms.
% Thus from target off, the following 250 ms is considered "visual".
% Allow another 150 ms for visual-evoked activity to "settle".
% Therefore start memory activity 400 ms after cue off.
% Saccade activity is ~300 ms prior to saccade on.
% So, we would need to go from 400 ms after cue off to ~700ms. Will give
% slightly more time, 800 ms. So there may be ~100 ms overlap with saccade.
% Note that there is no memory-related activity for some tasks

window_width = [0, 800];
event_idx = ~isnan(tmp.times.('target_off'));
[~,memory] = plotPSTHAligned(tmp,'target_off',window_width,[],[],0,0);
epochs.memory(unit_idx,event_idx) = mean(memory(400:end,:),'omitnan');

end