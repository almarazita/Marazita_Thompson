clean_dir = "/Users/lowell/Library/CloudStorage/Box-Box/GoldLab/Data/Physiology/AODR/Data/MrM/Converted/Sorted/Mat_Cleaned/All_Refined";

% Get the names of the .mat files in the folder
folder_struct = dir(clean_dir);
filenames = extractfield(folder_struct, "name");
filenames = string(filenames((contains(filenames,'.mat'))));

% Load the data to look like sessionToUnitData output
for idx=1:length(filenames)
    fprintf('loading unit: %d/%d \n',idx,length(filenames))
    cur_filename = filenames(idx);
    % Each contains current_data and current_table
    load(clean_dir+"/"+cur_filename);
    if idx == 1
        unit_table = current_table;
        unit_data = current_data;
    else
        unit_data = cat(1,unit_data,current_data);
        unit_table = cat(1,unit_table,current_table);
    end
end