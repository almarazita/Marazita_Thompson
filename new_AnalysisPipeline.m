% So right now the pipeline is:
%% 1) new_loadClean
new_loadClean

%% 2) new_sessionToUnitData
[unit_data, unit_table] = new_sessionToUnitData(all_pyr_cleaned_data);
clear all_pyr_cleaned_data
new_unit_table = table();
%% 3) TBD: new_epochData
for u = 1:size(unit_table,1)
    fprintf('\nEpoching data for unit %d/%d',u,size(unit_table,1));
    epoched_data(u) = new_epochData(unit_data(u),1,1);

    %% 4) TBD: new_SingleUnitGLMs
    unit_table = newSingleUnitGLMs(epoched_data(u),unit_table,u);
end

