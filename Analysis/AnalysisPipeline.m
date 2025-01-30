%% This script illustrates the steps taken to process/analyze cleaned AODR data
% Written by LWT 10/16/2024

clear all
close all
clc

% pick structure to load
load_type = 'refined';

%% 1) Load cleaned/refined AODR sessions that only contain units of interest
switch load_type
    case 'cleaned'
        loadClean
        % OR Run clean.m to generate the cleaned data structures, then load.
        [unit_data, unit_table] = sessionToUnitData(all_pyr_cleaned_data);
        % remove the session data structure to save memory
        clear all_pyr_cleaned_data

    case 'refined'
        loadRefined
        % OR Run refine.m to further refine cleaned sessions.
end

%% 4) EpochData: segments trials into different averaged epochs (e.g., visual/memory/saccade)
for u = 1:size(unit_table,1)
    fprintf('Epoching data for unit %d/%d\n',u,size(unit_table,1));
    unit_data(u).epochs = epochData(unit_data(u),1,1);

    % TO DO: 
    % 1) epoched data will have a different size of many of the fields - should be fixed above
    % 2) either overwrite the unit data (or added epoched data) or clear the unit data since this
    % is super redundant and we end up with identical data, one with an
    % extra field.

    %% 4) new_SingleUnitGLMs: run some simple statistics for each unit
    %unit_table = SingleUnitGLMs(unit_data(u),unit_table,u);

    % plotAODR_sessionNeural_Overview(unit_data(u), [], 1);
end


