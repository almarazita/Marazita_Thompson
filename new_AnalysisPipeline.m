%% This script illustrates the steps taken to process/analyze cleaned AODR data
% Written by LWT 10/16/2024

clear all
close all
clc

%% 1) new_loadClean: loads cleaned AODR that only contains units of interest
new_loadClean

% OR Run clean.m to generate the cleaned data structures, then load.

%% 2) new_sessionToUnitData: convert cell array of sessions to cell arrays by unit
[unit_data, unit_table] = new_sessionToUnitData(all_pyr_cleaned_data);
% remove the session data structure to save memory
clear all_pyr_cleaned_data

%% 3) new_epochData: segments trials into different averaged epochs (e.g., visual/memory/saccade)
for u = 1:size(unit_table,1)
    fprintf('\nEpoching data for unit %d/%d',u,size(unit_table,1));
    unit_data{u}.epochs = new_epochData(unit_data(u),1,1);

    % TO DO: 
    % 1) epoched data will have a different size of many of the fields - should be fixed above
    % 2) either overwrite the unit data (or added epoched data) or clear the unit data since this
    % is super redundant and we end up with identical data, one with an
    % extra field.

    %% 4) new_SingleUnitGLMs: run some simple statistics for each unit
    unit_table = newSingleUnitGLMs(unit_data(u),unit_table,u);

    %% 5) Create a population data matrix
        % It might be useful to do this in a separate script or add
        % conditional argument?
        % Psuedopopulation/repeated random subsampling
        % Save the matrix?
end


