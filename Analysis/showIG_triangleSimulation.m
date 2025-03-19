function tiledlayout_ = showIG_triangleSimulation(states, samples, beliefs, priors, LLRs, options)
% function tiledlayout_ = showIG_triangleSimulation(states, samples, beliefs, priors, LLRs, options)
%

arguments
    states
    samples
    beliefs
    priors
    LLRs
    options.maxSamplesToShow = 1000;
    options.gMean = 1;
    options.tiledlayout = [];
end

% Anonymyty!
clearPlot = @(h) set(h, 'XData', [], 'YData', []);
pFromBelief = @(beliefs) 1./(1+exp(-beliefs));
dkl = @(p1,p2) sum(p1.*log(p1./p2));
negentropy = @(ps) ps.*log(ps)+(1-ps).*log(1-ps);
dklFromBelief = @(b1,b2) dkl([pFromBelief(b1) 1-pFromBelief(b1)], [pFromBelief(b2) 1-pFromBelief(b2)]);
neFromBelief = @(belief) negentropy(pFromBelief(belief));

% Set up plotz
if isempty(options.tiledlayout)

    % Make the layout
    tiledlayout_ = tiledlayout(5,2);

    % 1: triangles
    nexttile(1,[1 2])
    hold on
    userData.triangles = [ ...
        plot(-options.gMean, 0, 'k^', 'MarkerSize', 10), ...
        plot( options.gMean, 0, 'k^', 'MarkerSize', 10)];        
    userData.stars = plot(0, 0, 'r*', 'MarkerSize', 10);
    clearPlot(userData.stars);
    axis(cat(2, options.gMean.*[-2 2], [-0.5 0.5]));

    % 2: state/sample (star) history
    nexttile(3,[1 2])
    hold on
    plot([-options.maxSamplesToShow+1 0], [0 0], 'k:');
    userData.state = plot(0, 0, 'k-', 'LineWidth', 2);
    clearPlot(userData.state);
    userData.sample = plot(0, 0, '-', 'Color', 0.5.*ones(3,1));
    clearPlot(userData.sample);
    axis(cat(2, [-options.maxSamplesToShow+1 0], options.gMean.*[-2 2]));
    xlabel('Sample number re: now')
    ylabel('Horizontal location')

    % 3: ideal observer output
    nexttile(5,[1 2])
    hold on
    plot([-options.maxSamplesToShow+1 0], [0 0], 'k:');
    userData.prior = plot(0, 0, 'r-');
    clearPlot(userData.prior);
    userData.LLR = plot(0, 0, 'g-');
    clearPlot(userData.LLR);
    userData.belief = plot(0, 0, 'b-');
    clearPlot(userData.belief);
    axis(cat(2, [-options.maxSamplesToShow+1 0], options.gMean.*[-3 3]));
    xlabel('Sample number re: now')
    ylabel('Belief strength')

    % 4: Negentropy (prev and current values)
    nexttile(7,[1 2])
    hold on
    ps = 0:0.001:1;
    plot(ps, negentropy(ps), 'k-');
    userData.negentropy = [ ...
        plot(0, 0, 'ko', 'MarkerSize', 10, 'MarkerFaceColor', 0.99.*ones(3,1))
        plot(0, 0, 'ro', 'MarkerSize', 10, 'MarkerFaceColor', 'r')];
    clearPlot(userData.negentropy);
    axis([0 1 -1 0.1]);
    xlabel('P(believe right)')
    ylabel('Negentropy')

    % 5: Comparisons
    nexttile(9,[1 1])
    hold on
    userData.ic = [ ...
        plot(nan(50,1), nan(50,1), 'ko', 'MarkerSize', 10, 'MarkerFaceColor', 0.99.*ones(3,1))
        plot(nan, nan, 'ro', 'MarkerSize', 10, 'MarkerFaceColor', 'r')];
    axis([0 1 -3 3]);
    xlabel('Prior update')
    ylabel('I^c')

    nexttile(10,[1 1])
    hold on
    plot([-1 1], [-1 1], 'k:');
    userData.ir = [ ...
        plot(0, 0, 'ko', 'MarkerSize', 10, 'MarkerFaceColor', 0.99.*ones(3,1))
        plot(0, 0, 'ro', 'MarkerSize', 10, 'MarkerFaceColor', 'r')];
    clearPlot(userData.ir(1));
    % axis([0 1 -1 0.1]);
    xlabel('Posterior update')
    ylabel('I^r')

    % save the userdata
    set(tiledlayout_, 'UserData', userData);
else
    tiledlayout_ = options.tiledlayout;
end

% Check for data
if ~isempty(samples)

    % Add data
    % Figure out size of data vectors to show
    numOldSamples = length(tiledlayout_.UserData.state.XData);
    numNewSamples = length(samples);
    numSamples = min(options.maxSamplesToShow, numOldSamples+numNewSamples);
    numOldSamplesToKeep = numSamples-numNewSamples;
    xAxis = -numSamples+1:0;

    % Get previous belief
    if isempty(tiledlayout_.UserData.belief.YData)
        lastBelief = 0.5;
    else
        lastBelief = tiledlayout_.UserData.belief.YData(end);
    end

    % Update star(s)
    set(tiledlayout_.UserData.stars, ...
        'XData',    samples, ...
        'YData',    zeros(size(samples)));
    if isscalar(samples)
        if states == 0
            set(tiledlayout_.UserData.triangles(1), 'MarkerFaceColor', 'r');
            set(tiledlayout_.UserData.triangles(2), 'MarkerFaceColor', 0.99.*ones(1,3));
        else
            set(tiledlayout_.UserData.triangles(1), 'MarkerFaceColor', 0.99.*ones(1,3));
            set(tiledlayout_.UserData.triangles(2), 'MarkerFaceColor', 'r');
        end
    end

    % Update beliefs/etc
    updateData = @(name, data) set(tiledlayout_.UserData.(name), ...
        'XData',    xAxis, ...
        'YData',    [tiledlayout_.UserData.(name).YData(end-numOldSamplesToKeep+1:end) flip(data)]);
    updateData('state', (2.*states-1).*options.gMean);
    updateData('sample', samples);
    updateData('belief', beliefs);
    updateData('prior', priors);
    updateData('LLR', LLRs);

    % Update negentropy
    set(tiledlayout_.UserData.negentropy(1), ...
        'XData',    tiledlayout_.UserData.negentropy(2).XData, ...
        'YData',    tiledlayout_.UserData.negentropy(2).YData);
    ps = 1./(1+exp(-beliefs));
    set(tiledlayout_.UserData.negentropy(2), ...
        'XData',    ps, ...
        'YData',    negentropy(ps));

    % Update comparisons
    if ~isempty(lastBelief)

        % prior update vs ic
        tiledlayout_.UserData.ic(1).XData = circshift(tiledlayout_.UserData.ic(1).XData,-1);
        tiledlayout_.UserData.ic(1).XData(end) = tiledlayout_.UserData.ic(2).XData;
        tiledlayout_.UserData.ic(1).YData = circshift(tiledlayout_.UserData.ic(1).YData,-1);
        tiledlayout_.UserData.ic(1).YData(end) = tiledlayout_.UserData.ic(2).YData;
        
        ic = neFromBelief(beliefs(end)) - neFromBelief(lastBelief);
        kl = dklFromBelief(beliefs(end), neFromBelief(lastBelief));
        ir = kl-ic;
        set(tiledlayout_.UserData.ic(2), ...
            'XData', priors(end)./lastBelief, ...
            'YData', ic./kl)
        
        % belief update vs ir
        set(tiledlayout_.UserData.ir(2), ...
            'XData', tiledlayout_.UserData.ir(1).XData, ...
            'YData', tiledlayout_.UserData.ir(1).YData);
        set(tiledlayout_.UserData.ir(1), ...
            'XData', beliefs(end) - priors(end), ...
            'YData', ir./kl)
    end
end