function plotSwitchPSTH(data,u,axs)
%% Plot the mean time-courses of each neuron for switch vs no switch trials, low hazard rate
% when aligned to multiple different events
% data: 1 x 1 struct with 8 fields for a session
% u: current unit id to plot
% axs: current axes to use for plotting

if isempty(axs)
    figure; hold on;
end

% n_units = length(data.spikes.id);
n_trials = data.header.validTrials;

%  Compute choice switch (0/1)
choice = data.ids.choice; % Get the monkey's choice for each trial, 1=T1, 2=T2
% switch_bool = zeros(length(choice),1); % Initialize switch boolean to column vector of zeros
% for i = 1:length(choice)-1 % For each trial except the last one
%      if choice(i)-choice(i+1) ~= 0 % If the monkey's current choice is not the next choice
%          switch_bool(i+1) = 1; % The monkey switched on the next choice
%      end
% end

% What the previous correct target was
prevState = [nan; data.ids.correct_target(1:end-1)];
switch_bool = zeros(length(choice),1);
% The monkey switched if its current choice is not what was previously correct
switch_bool(choice~=prevState)=1;
% If the previous state or current choice are NaN, then so is switch
switch_bool(~ismember(choice, [1 2]) | ...
    ~ismember(prevState,[1 2])) = nan;

switch_leg = {'No Switch','Switch'};

window_width = {[300,600],[300,100]}; % for each code, time before, time after
codes = {'sample_on','sac_on'}; %'fp_off','target_off'
co = {[.87 .55 .41],[.19 .74 .38]};
p=[];

if ~any(data.values.hazard == 0.05)
    fprintf('\nNo low hazard trials\n')
else
    % for u = 1:n_units
    % figure_handle(u) = figure; hold on;
    for c = 1:length(codes)
        event_code = codes{c};
        for s = 1:2
            if isempty(axs)
                axs = subplot(2,1,c); hold on;
            else
                %axes(ax(c)); hold on;
                ax = axs(c); hold on;
            end
            % ax = subplot(2,1,c); hold on;
            % title(['U: ', num2str(data.spikes.id(u))]);
            criteria = switch_bool==(s-1) & data.values.hazard==0.05;
            tmp.binned_spikes = squeeze(data.binned_spikes(u,:,criteria));
            tmp.values = data.values(criteria,:);
            tmp.times = data.times(criteria,:);
            p(s) = plotPSTHAligned(tmp,event_code,window_width{c},ax,co{s},1);
        end
        if isempty(axs)
            filename = data.data.header.filename;
            startIdx = strfind(filename, 'MM');
            endIdx = strfind(filename, '.hdf5') - 1;
            sessionName = filename(startIdx:endIdx);
            sgtitle([sessionName ' Unit: ' num2str(data.spikes.id(u))], 'Interpreter', 'none');
            legend(p,switch_leg)
        else
            title('Switch in Low Hazard')
            if c == 1
                % legend(p,switch_leg)
            end
        end
    end
    % end
end
