%% Select and refine neurons after inspection
save_directory = ['/Users/lowell/Library/CloudStorage/Box-Box/GoldLab/Data/Physiology/' ...
    'AODR/Data/MrM/Converted/Sorted/Mat_Cleaned/All_Refined/']; % location of final cleaned files

%% 1) Load cleaned AODR sessions that had good sorts
loadClean
% OR Run clean.m to generate the cleaned data structures, then load.

%% 2) Convert cell array of sessions to cell array by unit
[unit_data, unit_table] = sessionToUnitData(all_pyr_cleaned_data);
clear all_pyr_cleaned_data

%% 3) Apply filter based on some criteria
% In this case, we load an excel sheet that identifies which of these
% neurons have stable baselines.
clean_sorts_table = readtable('clean_sorts_table.xlsx');

if size(clean_sorts_table,1) ~= size(unit_table,1)
    error('size of the excel sheet does not match the size of your unit table')
end

% Because we don't know if everything is in the same order, step through
% each unit
h = waitbar(0,'Saving refined data...');
for u = 1:length(unit_data)
    waitbar(u/length(unit_data),h);
    current_fileName = extractAfter(unit_table.fileName{u},'Pyramid/');
    ind = find(strcmp(current_fileName,clean_sorts_table.fileName) &...
        clean_sorts_table.unit_id == unit_table.unit_id(u));
    % Check criteria for matching unit
    if clean_sorts_table.Stable(ind) & clean_sorts_table.BaselineMin(ind)
        % Saving in new location
        current_data = unit_data(u);
        current_table = unit_table(u,:);
        mat_fullPath = strcat(save_directory, extractBefore(current_fileName,'.'), '_U', num2str(unit_table.unit_id(u)), '.mat');
        save(mat_fullPath, 'current_data', 'current_table', '-v7.3');
        % fprintf('Saved %s\n', strcat(extractBefore(current_fileName,'.'), '_U', num2str(unit_table.unit_id(u))))
    end
end
close(h)
fprintf('Done Refining\n')