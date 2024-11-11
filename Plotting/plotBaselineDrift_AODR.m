function [tmp_mean] = plotBaselineDrift_AODR(data,unit,event_code,t_before_event,ax,pltFlg)
% computes mean firing rates for each trial over time window =
% t_before_event:event_code
event_idx = round(data.times.(event_code)*1000); % Event time in ms
event_idx = event_idx(~isnan(data.times.(event_code))); % Keep non-NaN times
unit_spikes = squeeze(data.binned_spikes(unit,:,~isnan(data.times.(event_code)))); % ms x trials with non-NaN event times
task_ids = data.ids.task_id(~isnan(data.times.(event_code))); % Task ids for trials with non-NaN event times
data.values(isnan(data.times.(event_code)),:) = []; % Keep rows of values for trials with non-NaN event times

if isempty(pltFlg)
    pltFlg = 1;
end
if pltFlg
    if isempty(ax)
        figure; hold on;
    else
        axes(ax); hold on;
    end
end

tmp = cell2mat(arrayfun(@(x) circshift(unit_spikes(:,x),[-1*(event_idx(x)+1)+t_before_event])',(1:numel(event_idx))','un',0))';
tmp_mean = mean(tmp(1:t_before_event+1,:),1,'omitnan'); % take mean over these 300 ms
conditions = nonanunique(data.ids.task_id);
if sum(ismember(conditions,0))>0 % not sure what this is from, occasionally everything is nans but the task id says "0"
   conditions(conditions==0) = []; 
end
co = {[0 0 0], [4 94 167]./255, [194 0 77]./255}; % colors for plotting
if pltFlg
    for c = 1:length(conditions)
        color = co{conditions(c)};
        t_nums = find(task_ids == conditions(c));
        baseline = tmp_mean(task_ids == conditions(c));
        p(c) = plot(t_nums,baseline,'o','MarkerFaceColor',color,'MarkerEdgeColor',color);
    end
    kernel = ones(1,20)./20; % # trials to average
    smoothed_mean = convn(tmp_mean,kernel,'same'); % running average
    plot(1:length(tmp_mean),smoothed_mean,'-g','LineWidth',4)
    lims = axis;
    xlabel(['Trial #'])
    ylabel('Firing Rate (spikes/s)')
    if isempty(ax)
    title(['U:' , num2str(data.spikes.id(unit))])
    else 
        title('Baseline Firing Rate')
    end
end
end