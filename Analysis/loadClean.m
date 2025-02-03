% Loads cleaned session-based data structures from each pyramid-converted
% Mr. M recording session into a cell array to be used.

% Define filepath to Cleaned Data folder
% username = input("Enter your username in double quotes: ");
clean_dir = "/Users/GoldLab/Box/GoldLab/Data/Physiology/AODR/Data/MrM/Converted/Sorted/Mat_Cleaned/All_Cleaned";

% Get the names of the .mat files in the folder
folder_struct = dir(clean_dir);
filenames = extractfield(folder_struct, "name");
filenames = string(filenames((contains(filenames,'.mat'))));

% Load the data into a sessions x 1 cell array
all_pyr_cleaned_data = cell(length(filenames), 1);
for idx=1:length(filenames)
    fprintf('loading file: %d/%d \n',idx,length(filenames))
    cur_filename = filenames(idx);
    % Each cell is a data struct with 11 fields
    all_pyr_cleaned_data{idx} = load(clean_dir+"/"+cur_filename).data;
end