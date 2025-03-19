function [samples_, states_] = getIG_trianglesTaskSamples(options)
% function [samples_, states_] = getIG_trianglesTaskSamples(options)
%
% samples_ are unbounded
% states_ are [0,1]

arguments
    options.gMean = 1;
    options.gSTD = 1;
    options.hazard = 0.3;
    options.startState = 0;
    options.numTrials = 10000;
end

% Find change points
cps = find(binornd(1,options.hazard,options.numTrials,1));

% Set states
states_ = repmat(options.startState,options.numTrials,1);
if ~isempty(cps)
    if mod(length(cps),2) == 1
        cps = cat(1,cps,options.numTrials);
    end
    for ii = 1:2:length(cps)
        states_(cps(ii):cps(ii+1)) = 1 - options.startState;
    end
end

% Get samples
samples_ = normrnd((states_.*2-1).*options.gMean, options.gSTD);
