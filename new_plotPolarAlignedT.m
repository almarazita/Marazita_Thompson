%% TO DO: THIS SCRIPT IS 
%1) super excessive and messy
%2) not using the correct times (e.g., the spike time mat is in ms but the time values are in secs)

function p = new_plotPolarAlignedT(data,ecodes,timing,alignment,window_size,num,ax)
%
%polaraxes(ax); hold on;

if isempty(ax)
    figure; hold on;
else
axPosition = get(ax, 'Position');
axXLim = get(ax, 'XLim');
axYLim = get(ax, 'YLim');

% Create a polar axes at the same position
pax = polaraxes('Position', axPosition);

% Set the limits of the polar axes to match the Cartesian axes
set(pax, 'RLim', axYLim);
set(pax, 'ThetaLim', axXLim);

% Copy the children (e.g., plots, labels) from the original axes to the polar axes
copyobj(get(ax, 'Children'), pax);

delete(ax);

end


%declare structs
s_fr = NaN(1,length(data)); %firing rate per sample location
s_std = NaN(1,length(data)); %standard deviation per sample location
s_error = NaN(1,length(data)); %standard error per sample location
s_angle = NaN(1,length(data)); %angle of each sample location

%params
%v_latency = 120;  %set visual latency param in ms
%loop through sample locations


for i =1:length(data)
    data_sample = data{i}; %data for this sample 

    if strcmp(char(alignment), 'sample_on')
        start_t = timing{i}.(char(alignment)); %start times for this sample
        end_t = start_t+window_size; 
    elseif strcmp(char(alignment), 'sac_on')
        end_t = timing{i}.(char(alignment)); %end times for this sample
        start_t = end_t-window_size; 
    end

    %start_t = timing{i}.(char(start_code)); %start times for this sample
    %end_t = timing{i}.(char(end_code)); %end times for this sample

    angle = atan(ecodes{i}.t1_y(1)/(ecodes{i}.t1_x(1))); %calculate angle of sample location
    if ecodes{i}.t1_x(1) < 0 
        s_angle(i) = pi + angle; 
    elseif ecodes{i}.t1_y(1) == -10 
         s_angle(i) = pi + (angle)*-1; 
    elseif ecodes{i}.t1_y(1) < 0 && ecodes{i}.t1_x(1) > 0 && ecodes{i}.t1_x(1) < 10
        s_angle(i) = 2*pi + angle; 
    else
         s_angle(i) = angle; 
    end
%     %specify aspects of the time windows
%     if strcmp(char(start_code), 'sample_on')
%         end_t = end_t+v_latency;
%     elseif strcmp(char(start_code), 'target_off')
%         start_t = start_t + v_latency;
%         %do we want the end of this time window to be the start of the
%         %saccade?
%     elseif strcmp(char(start_code), 'sac_on')
%     end

    fr_trial = NaN(1,length(data_sample(i,:))); %struct for firing of each trial
     %loop through each trial
     for t = 1:length(end_t)
        data_cur = data_sample(:,t); %data for this trial
        criteria_st = data_cur>start_t(t); %index of spikes that occur after the start time
        criteria_en = data_cur<end_t(t); %index of spikes that occur before the end time
        sp_ind = criteria_st.*criteria_en; %index of spikes that occur within the time window
        fr_trial(t) = sum(sp_ind)/((end_t(t)-start_t(t))*.001); %fr rate for this trial in spikes/second
    end
    s_fr(i) =  nanmean(fr_trial); %mean(fr_trial,[],'omitnan');
    s_std(i) = nanstd(fr_trial); %std(fr_trial,[],'omitnan');
    s_error(i) = s_std(i)/sqrt(length(fr_trial));
end

[s_angle_sort, sort_i] = sort(s_angle);
s_fr_sort = s_fr(sort_i);

s_angle_sort(length(s_angle_sort)+1) = s_angle_sort(1); 
s_fr_sort(length(s_fr_sort)+1) = s_fr_sort(1); 
%figure
if isempty(ax)
subplot(2,1,num); 
end
p = polarplot(pax,s_angle_sort,s_fr_sort,'bo-', 'MarkerSize', 8, 'LineWidth', 1.5, 'MarkerFaceColor', 'blue');
title(['Aligned to ' char(alignment)],'Interpreter', 'none')
end
