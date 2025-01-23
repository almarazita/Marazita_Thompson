%% This script illustrates the steps taken to process/analyze cleaned AODR data
% Written by LWT 10/16/2024

clear all
close all
clc

%% 1) new_loadClean: loads cleaned AODR that only contains units of interest
loadClean

% OR Run new_clean.m to generate the cleaned data structures, then load.

% TO DO: 
% Clean our directories
    % 1) Github
        % a) Lets start making some subfolders
    % 2) Ensure that we have a folder of raw data (uncleaned) and remove
        % others we don't need anymore
    % 3) Ensure we have cleaned data in its own folder
        % a) Cleaned pupil, cleaned units, only valid trials for all data
            % structs
        % b) Remove redundant information to reduce the size of the cleaned
            % files

%% 2) new_sessionToUnitData: convert cell array of sessions to cell arrays by unit
[unit_data, unit_table] = sessionToUnitData(all_pyr_cleaned_data);
% remove the session data structure to save memory
clear all_pyr_cleaned_data

%% 3) new_epochData: segments trials into different averaged epochs (e.g., visual/memory/saccade)
for u = 1:size(unit_table,1)
    fprintf('\nEpoching data for unit %d/%d',u,size(unit_table,1));
    unit_data(u).epochs = epochData(unit_data(u),1,1);

    % TO DO: 
    % 1) epoched data will have a different size of many of the fields - should be fixed above
    % 2) either overwrite the unit data (or added epoched data) or clear the unit data since this
    % is super redundant and we end up with identical data, one with an
    % extra field.


    %% 4) new_SingleUnitGLMs: run some simple statistics for each unit
    %unit_table = SingleUnitGLMs(unit_data(u),unit_table,u);

    %% 5) Create a population data matrix
        % It might be useful to do this in a separate script or add
        % conditional argument?
        % Psuedopopulation/repeated random subsampling
        % Save the matrix?
end


