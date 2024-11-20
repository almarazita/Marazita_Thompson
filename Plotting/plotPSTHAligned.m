function [p, tmp2] = plotPSTHAligned(data,event_code,window_width,ax,colors,plotErr,pltFlg)
%% function [p, tmp2] = plotPSTHAligned(data,event_code,window_width,ax,colors,plotErr,pltFlg)
% Aligns spike data to a given event code and plots averages relative to a
% a given window.
%
% Input args:
% data:                 data struct from goldLabDataSession
% event_code:           string of the event code label to align to: e.g., 'fp_on'
% window_width:         1x2 array specifying the time before and the time after the event that you want to include. Optional: a single value to use for both
% ax:                   optional axis to plot into
% colors:               1x3 array specifying the color of the plot
% plotErr:              boolean to indicate whether you want to include a shaded error bar.
% pltFlag:              boolean specifying to plot or just return the aligned data
%
% Created by LWT 11/8/24

arguments
    data = [];
    event_code = 'fp_on';
    window_width = [300 300]; % ms before/after
    ax = [];
    colors = [0 0 0];
    plotErr = 1;
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

if length(window_width) == 1
    window_width(end+1) = window_width(1); % single value entered, make it symmetrical
end

event_idx = round(data.times.(event_code)*1000) + 1; % time 0 = index 1
event_idx = event_idx(~isnan(data.times.(event_code)));
if ndims(data.binned_spikes)<3
    unit_spikes = squeeze(data.binned_spikes(:,~isnan(data.times.(event_code)))); % ms x trial
else
    unit_spikes = squeeze(data.binned_spikes(1,:,~isnan(data.times.(event_code)))); % unit x ms x trial
end

tmp2 = nan(sum(window_width)+1,size(unit_spikes,2));

for t_num = 1:size(unit_spikes,2)
    % Check that your trial has sufficient time before/after the event
    start_ind = event_idx(t_num)-(window_width(1)); % can't go back further than the first index
    end_ind = event_idx(t_num)+window_width(2); % can't exceed the last index
    % size(unit_spikes,1)
    window_adj = [0,0];
    if start_ind<1 && end_ind>size(unit_spikes,1)
        % If there is not enough time before, it needs to be shifted in the
        % new matrix to still align with other trials!
        window_adj(1) = abs(start_ind) + 1; % value of -1 shifts 2...
        start_ind = 1;
        % Don't think you need to shift if you don't have enough after?
        end_ind = size(unit_spikes,1);
        warning(['Time before and after event code are exceeded for trial: ',num2str(t_num)]);
    elseif start_ind<1
        % If there is not enough time before, it needs to be shifted in the
        % new matrix!
        window_adj(1) = abs(start_ind) + 1; % value of -1 shifts 2...
        start_ind = 1;
        warning(['Time before event code exceeds start time for trial: ',num2str(t_num)]);
    elseif end_ind>size(unit_spikes,1)
        end_ind = size(unit_spikes,1);
        warning(['Time after event code exceeds trial length for trial: ',num2str(t_num)]);
    end
    tmp_trial = unit_spikes(start_ind:end_ind,t_num)';
    tmp2(window_adj(1)+1:size(tmp_trial,2),t_num) = tmp_trial;
end
if pltFlg
    tmp_mean = mean(tmp2,2,'omitnan'); %mean(tmp(1:window_width+1,:),2,'omitnan');
    if plotErr
        tmp_sem = std(tmp2,[],2,'omitnan')./sqrt(numel(event_idx));
        %     tmp_sem = std(tmp(1:window_width+1,:),[],2,'omitnan')./sqrt(numel(event_idx));
        shadedErrorBar(-window_width(1):window_width(2),tmp_mean,tmp_sem,'lineprops',{'-','Color',colors,'markerfacecolor',colors});
    end
    p = plot(-window_width(1):window_width(2),tmp_mean,'-','Color',colors);
    lims = axis;
    plot([0,0],[0,lims(4)],'--k')
    xlim([-window_width(1), window_width(2)]);
    % ylim([lims(3:4)]);
    xlabel(['Time From ', event_code], 'Interpreter', 'none')
    ylabel('Firing Rate (spikes/s)')
end
end