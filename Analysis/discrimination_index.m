%% Calculate visual discrimination index
function DI = discrimination_index(data)
%% DI = DiscriminationIndex(data) calculates a discrimination index given
% the matrix, data, which is an NxM matrix:
% N = trials
% M = conditions.
% Use NaN values to pad the matrix if there are unequal trials.
% See: Prince SJD, Pointon AD, Cumming BG, Parker AJ. 2002. 
% Quantitative analysis of the responses of V1 neurons to horizontal 
% disparity in dynamic random-dot stereograms. 
% Journal of Neurophysiology 87:191–208. DOI: https://doi.org/10.1152/jn.00465.2000

% Written by LWT 10/31/23

mean_data = nanmean(data, 1); % mean over trials
R_max = max(mean_data);
R_min = min(mean_data);
M = size(data,2);
N = sum(~isnan(data(:)));
errors = data - mean_data;
SSE = sum(errors(:).^2, 'omitnan');

DI = (R_max - R_min)/...
    ((R_max - R_min) + 2*sqrt(SSE/(N-M)));

end