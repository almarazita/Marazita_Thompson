function runIG_triangleSimulation(options)
% function runIG_triangleSimulation(options)
%

arguments
    % Set task parameters
    options.gMean = 1;
    options.gSTD = 2.5; %0.1;
    options.hazard = 0.05;
    options.numTrials = 1000;
    options.trialsPerIteration = 1;
    options.maxSamplesToShow = 100;
    options.pauseBetweenFrames = 0.1; % sec
    options.newFigure = false;
end

% Set up plotz
if options.newFigure
    figure
end
tl = showIG_triangleSimulation([],[],[],[],[], ...
    'maxSamplesToShow', options.maxSamplesToShow, ...
    'gMean',            options.gMean);

% Loop one trial at a time
beliefs = 0;
states = randi(2)-1;
for tt = 1:round(options.numTrials/options.trialsPerIteration)

    % Get task output
    [samples, states] = getIG_trianglesTaskSamples(...
        'gMean',            options.gMean, ...
        'gSTD',             options.gSTD, ...
        'hazard',           options.hazard, ....
        'numTrials',        options.trialsPerIteration, ...
        'startState',       states(end));

    % Get ideal observer output
    [beliefs, priors, LLRs] = getIG_trianglesIdealObserver(samples, ...
        'gMean',            options.gMean, ...
        'gSTD',             options.gSTD, ...
        'hazard',           options.hazard, ....
        'prior',            beliefs(end));

    % Update plotz
    showIG_triangleSimulation(states, samples, beliefs, priors, LLRs, ...
        'tiledLayout',      tl);    

    % Pause
    r = input('next')
    %pause(options.pauseBetweenFrames);
end