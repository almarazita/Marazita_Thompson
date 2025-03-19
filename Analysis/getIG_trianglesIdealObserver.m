function [belief_, prior_, LLR_] = getIG_trianglesIdealObserver(samples, options)
% function [belief_, prior_, LLR_] = getIG_trianglesIdealObserver(samples, options)
%
% samples are star positions

arguments
    samples
    options.gMean = 1;
    options.gSTD = 1;
    options.hazard = 0.3;
    options.prior = 0;
end

% Compute LLR per sample
LLR_ = log(normpdf(samples,options.gMean,options.gSTD)) - ...
    log(normpdf(samples,-options.gMean,options.gSTD));

% Set up prior, belief vectors vector
prior_ = nan(size(samples));
belief_ = nan(size(samples));
lastBelief = options.prior;

% Loop through trials, updating prior and belief
hScale = (1-options.hazard)./options.hazard;
for ii = 1:length(samples)
    prior_(ii) = lastBelief + log(hScale+exp(-lastBelief)) - ...
        log(hScale+exp(lastBelief));
    belief_(ii) = prior_(ii) + LLR_(ii);
    lastBelief = belief_(ii);
end
