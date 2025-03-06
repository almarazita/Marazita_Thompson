function [raw_ROC, ROC_percentiles] = GrandChoiceProb_Permutation(stimulus_responses, pref, Trial_min, num_bootstraps)
% Grand Choice Probability computation
% [raw_ROC, ROC_percentiles] = GrandChoiceProb_Permutation(stimulus_responses, pref, Trial_min, num_bootstraps)
% Generates a z-scored choice probability analysis based on the
% stimulus_resposes for a 2AFC task. "stimulus_responses" is a 2xN cell array,
% each column representing a single stimulus value. Each cell in a column
% consists of a vector, one for each choice. "preferred" represents the
% index of the vector that is considered the cell's "preferred" choice (1 or 2).
% Trial_min is the minimum number of trials needed for each stimulus value
% to be included in the analysis.
% Note: Cells are used because there are likely an unequal number of trials
% for each choice and each stimulus value.

% Created 1/9/19 - LT

plotFlag = 0;
thresh_step_size = 0.001; % Increment size by which you "slide" your threshold across the distributions to determine hits and false alarm rates
% Make sure you remove nans before counting trials
nan_cleaned = cellfun(@(x) x(~isnan(x)), stimulus_responses, 'UniformOutput', false);
stimulus_responses = nan_cleaned;
valid_stimuli = cellfun(@length, stimulus_responses) >= Trial_min; % Find cells that meet the minimum trial count
valid_stimuli = find(valid_stimuli(1,:) & valid_stimuli(2,:)); % Find stimuli that meet the minimum trial count for both choices

if ~isempty(valid_stimuli)
    stim_z_responses{1} = [];
    stim_z_responses{2} = [];
    for s = 1:length(valid_stimuli)
        % To avoid underestimation of the choice probability, we normalize
        % neuronal responses within a stimulus condition as if the samples for
        % the two behavioral choices had an equal number of trials (Kang &
        % Maunsell, 2012)
        stim = valid_stimuli(s);
        
        temp_all_responses = [stimulus_responses{1,stim}, stimulus_responses{2,stim}];
        mu(1) = mean(stimulus_responses{1,stim});
        mu(2) = mean(stimulus_responses{2,stim});
        sd(1) = std(stimulus_responses{1,stim});
        sd(2) = std(stimulus_responses{2,stim});
        n(1) = length(stimulus_responses{1,stim});
        n(2) = length(stimulus_responses{2,stim});
        
        mu_composite = (n(1)*mu(1) + n(2)*mu(2))/sum(n); % Kang & Maunsell, 2012 Eq. (3)
        sd_composite = sqrt(((n(1)*sd(1)^2 + n(2)*sd(2)^2)/sum(n)) + ((n(1)*n(2)*(mu(1)-mu(2))^2)/(sum(n)^2))); % Kang & Maunsell, 2012 Eq. (4)
        z_scored_all = (temp_all_responses - mu_composite)./sd_composite; % Balanced Z score of all your responses
        z_scored{1,s} = z_scored_all(1:length(stimulus_responses{1,stim})); % Break them back up into their choices
        z_scored{2,s} = z_scored_all(length(stimulus_responses{1,stim})+1:end);
        stim_z_responses{1} = [stim_z_responses{1}, z_scored{1,s}]; % Combine over multiple stimulus values for each choice
        stim_z_responses{2} = [stim_z_responses{2}, z_scored{2,s}];
    end
    
    for b = 1:num_bootstraps+1 % permutations (add one because the first round produces the "true" ROC based on the actual distributions provided (after composite z-scoring)
        % Select trials from the z-scored values pooled over all stimulus sets using random sampling
        % w/replacement
        if b == 1 % First bootstrap doesn't count- hence the add 1 above
            boot_responses{1} = stim_z_responses{1}; % This isn't a random sample, but it is helpful when debugging to see the raw data ROC value, and should be meaningless given enough bootstraps
            boot_responses{2} = stim_z_responses{2};
        else
            % Grab an equal number of random samples from both distributions to
            % create 2 new distributions:
            temp_responses{1} = randsample(stim_z_responses{1}, floor(max([length(stim_z_responses{1}),length(stim_z_responses{2})])/2),'true'); % Pull half your responses from the first group to make your first distribution
            temp_responses{2} = randsample(stim_z_responses{2}, floor(max([length(stim_z_responses{1}),length(stim_z_responses{2})])/2),'true'); % Pull other half of your respones from second group to complete your first distribution
            temp_responses{3} = randsample(stim_z_responses{1}, floor(max([length(stim_z_responses{1}),length(stim_z_responses{2})])/2),'true'); % Pull half your responses from the first group to make your second distribution
            temp_responses{4} = randsample(stim_z_responses{2}, floor(max([length(stim_z_responses{1}),length(stim_z_responses{2})])/2),'true'); % Pull other half of your respones from second group to complete your second distribution
            boot_responses{1} = [temp_responses{1}, temp_responses{2}]; % Merge samples to get your first distribution
            boot_responses{2} = [temp_responses{3}, temp_responses{4}]; % Merge samples to get your second distribution
        end
        
        if plotFlag == 1
            binsize = 0.2;
            % You need to pad your histograms to create stacked histograms
            sz = max(length(boot_responses{1}),length(boot_responses{2}));
            padded_stim{1} = nan(sz,1);
            padded_stim{2} = nan(sz,1);
            padded_stim{1}(1:length(boot_responses{1})) = boot_responses{1};
            padded_stim{2}(1:length(boot_responses{2})) = boot_responses{2};
            figure; hold on;
            % histogram([padded_stim{1},padded_stim{2}]);
            histogram([padded_stim{1},padded_stim{2}],'BinWidth',binsize)
            histogram(padded_stim{2},'BinWidth',binsize)
            legend({'Stim1','Stim2'});
            xlabel('Z Scored Firing Rate');
            ylabel('Frequency');
            axis square;
        end
        i=0;
        % Calculate your ROC manually
        for thresh = floor(min([boot_responses{1},boot_responses{2}])):thresh_step_size:ceil(max([boot_responses{1},boot_responses{2}]))
            i=i+1;
            if pref == 1
                Hits(i) = sum(boot_responses{1} > thresh)./length(boot_responses{1});
                FAs(i) = sum(boot_responses{2} > thresh)./length(boot_responses{2});
            else
                Hits(i) = sum(boot_responses{2} > thresh)./length(boot_responses{2});
                FAs(i) = sum(boot_responses{1} > thresh)./length(boot_responses{1});
            end
        end
        % You aren't gauranteed to get a (0,0) value, or (1,1), but
        % this is required to do a proper AUC estimate. Add a (0,0) or (1,1) point if it
        % doesn't exist
        if Hits(end)~=0 || FAs(end) ~= 0
            Hits(end+1) = 0;
            FAs(end+1) = 0;
        end
        if Hits(1)~=1 || FAs(1) ~= 1
            Hits = [1 Hits(:)];
            FAs = [1 FAs(:)];
        end
        ROC(b) = trapz(fliplr(FAs),fliplr(Hits)); % Find area under ROC curve (normalized FAs vs normalized Hits)
        if b == 1
            raw_ROC = ROC(b); % Use the "true" value for the ROC estimate
        end
        if plotFlag == 1
            figure;
            plot(FAs/max(FAs),Hits/max(Hits));
            ylabel(['Hit Proportion - Correctly Chose Stim ' num2str(pref)]);
            xlabel(['FAs - Incorrectly Chose Stim ' num2str(pref)]);
        end
        
        %% Using approximate fits of the distributions - NOT traditionally used
        %     [z_mu(1), z_sig(1)] = normfit(boot_responses{1});
        %     [z_mu(2), z_sig(2)] = normfit(boot_responses{2});
        %     stim = floor(min([boot_responses{1},boot_responses{2}])):thresh_step_size:ceil(max([boot_responses{1},boot_responses{2}]));
        %     i=0;
        %     for thresh = stim
        %         i=i+1;
        %         if pref == 1
        %             Fit_Hits(i) = normcdf(thresh,z_mu(1),z_sig(1),'upper');
        %             Fit_FAs(i) = normcdf(thresh,z_mu(2),z_sig(2),'upper');
        %         else
        %             Fit_Hits(i) = normcdf(thresh,z_mu(2),z_sig(2),'upper');
        %             Fit_FAs(i) = normcdf(thresh,z_mu(1),z_sig(1),'upper');
        %         end
        %     end
        %     if plotFlag == 1
        %         figure;
        %         plot(Fit_FAs,Fit_Hits);
        %     end
        %     fitted_ROC(b) = trapz(fliplr(Fit_FAs),fliplr(Fit_Hits));
    end
    % ROC_percentiles(1) = sum(ROC(2:end)<ROC(1))/num_bootstraps;
    % ROC_percentiles(2) = sum(ROC(2:end)>ROC(1))/num_bootstraps;
    
    ROC_percentiles = prctile(ROC(2:end),[5,95]);
else
    warning('No valid trials to compute an ROC, returning NaNs');
    raw_ROC = NaN;
    ROC_percentiles = nan(1,2);
end
% raw_ROC = mean(ROC);
% fitted_ROC_percentiles = prctile(fitted_ROC,[5,95]);
end

