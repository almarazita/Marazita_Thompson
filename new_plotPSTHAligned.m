function [p, tmp2] = new_plotPSTHAligned(data,event_code,window_width,ax,colors,plotErr,pltFlg)

if nargin<7
    pltFlg = 1;
end
if pltFlg
    if isempty(ax)
        figure; hold on;
    else
        axes(ax); hold on;
    end
else
    p = [];
end

event_idx = round(data.times.(event_code)*1000);
event_idx = event_idx(~isnan(data.times.(event_code)));
unit_spikes = squeeze(data.binned_spikes(:,~isnan(data.times.(event_code)))); % ms x trial

% You should be careful here. If the size of your shift relative to the
% size of your array, and the window width, is too large you could be averaging
% beginning and end trial spikes
% if window_width > (size(unit_spikes,1) - max(event_idx) + window_width/2)
%     warning('Your window width or alignment shift is too large and some mean values will be contaminated')
% end
% tmp = cell2mat(arrayfun(@(x) circshift(unit_spikes(:,x),[-1*(event_idx(x)+1)+window_width/2])',(1:numel(event_idx))','un',0))';
tmp2 = nan(window_width+1,size(unit_spikes,2));
for t_num = 1:size(unit_spikes,2)
    % an obvious note that if you want window_width/2 time points before an event, then you have window_width/2 + 1 indices including the event 
    tmp_trial = unit_spikes(max(1,event_idx(t_num)-window_width/2):min(size(unit_spikes,1),event_idx(t_num)+window_width/2),t_num)';
    if event_idx(t_num)-window_width/2 <=0 && event_idx(t_num)+window_width/2 > size(unit_spikes,1) % there is insufficient time in both directions
        tmp2((window_width/2 + 1) - event_idx(t_num) + 1 : (window_width/2 + 1) - event_idx(t_num) + length(tmp_trial), t_num) = tmp_trial;
%         tmp2(window_width/2 - event_idx(t_num) + 1:(window_width/2 - event_idx(t_num))+size(tmp_trial,2),t_num) = tmp_trial;
    elseif event_idx(t_num)-window_width/2 <=0 % there is insufficient time preceeding the event_idx
        tmp2((window_width/2 + 1) - event_idx(t_num) + 1:end,t_num) = tmp_trial;
    elseif event_idx(t_num)+window_width/2 > size(unit_spikes,1) % there is insufficient time after the event_idx
        tmp2(1:size(tmp_trial,2),t_num) = tmp_trial;
    else % sufficient time in both directions
        tmp2(:,t_num) = tmp_trial;
    end
end
if pltFlg
    tmp_mean = mean(tmp2,2,'omitnan'); %mean(tmp(1:window_width+1,:),2,'omitnan');
    if plotErr
        tmp_sem = std(tmp2,[],2,'omitnan')./sqrt(numel(event_idx));
        %     tmp_sem = std(tmp(1:window_width+1,:),[],2,'omitnan')./sqrt(numel(event_idx));
        shadedErrorBar(-window_width/2:window_width/2,tmp_mean,tmp_sem,'lineprops',{'-','Color',colors,'markerfacecolor',colors});
    end
    p = plot(-window_width/2:window_width/2,tmp_mean,'-','Color',colors);
    lims = axis;
    plot([0,0],[0,lims(4)],'--k')
    xlabel(['Time From ', event_code], 'Interpreter', 'none')
    ylabel('Firing Rate (spikes/s)')
end
end