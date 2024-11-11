% Mass Analysis
% Author: Annie
% Date: August 2024
% Description: script for extracting valid, sorted, and Pyramid-converted
% Mr. Miyagi data files regardless the style of units. We want to get all
% sessions converted to .mat files. Then, save another version where only
% relevant units are kept.

%% Setup
% Define the base path and load in the excel sheet
% Contains most recent sorted file for each session converted using Pyramid
base_directory = ['/Users/lowell/Library/CloudStorage/Box-Box/GoldLab/Data/Physiology/' ...
    'AODR/Data/MrM/Converted/Sorted/Pyramid/'];
master = readtable(['/Users/lowell/Library/CloudStorage/Box-Box/GoldLab/Analysis/AODR/' ...
    'MrM_Ci_Units.xlsx'], 'Format','auto');
save_directory = ['/Users/lowell/Library/CloudStorage/Box-Box/GoldLab/Data/Physiology/' ...
    'AODR/Data/MrM/Converted/Sorted/Mat_Cleaned/All_Cleaned/']; % location of final cleaned files

% Delete Cicero rows and get the list of Mr. M file names
master(~strcmp(master.Monkey,'MM'),:) = [];
files = master.Name;

%% Cleaning
% For each Mr. M file name in the spreadsheet
num_sessions = length(files);
error_files = {}; % Keep track of what couldn't get converted
for ifile = 1:num_sessions

    % Get and display its name
    fprintf(2,'\nExtracting file %i/%i\n', ifile, length(files))
    fileName = string(files(ifile));
    session_name = extractBefore(fileName, ".");
    if contains(session_name, "_S")
        session_name = extractBefore(session_name, "_S");
    end

    disp(session_name)

    % Get relevant units
    unit_id = convertStringToArray(string(master.Units(ifile)));
    
    % Skip this session if no units are given
    if isempty(unit_id)
        error_message = "No unit IDs given for " + session_name;
        disp(error_message);
        error_files{end+1} = error_message;
        continue
    else
        fprintf('Unit IDs: \n');
        disp(unit_id);
    end

    %% Conversion
    % Use convertSession function to convert .hdf5 pyramid output file
    % to .mat file, keeping only relevant units

    % Find the name of this session's .hdf5 file in the pyramid output
    % directory, or skip if it doesn't have one
    session_files = dir(fullfile(base_directory, session_name+'*'));
    if length(session_files) > 1
        fprintf('Multiple files matching current session found:\n');
        for file_num = 1:length(session_files)
            cur_name = session_files(file_num).name;
            fprintf('%s\n', cur_name);
            if endsWith(cur_name, ".hdf5")
                hdf5_fileName = cur_name;
            end
        end
        fprintf('Using %s\n', hdf5_fileName);

    elseif ~isempty(session_files) == 1
        hdf5_fileName = session_files.name;
        fprintf('hdf5_fileName = %s\n', hdf5_fileName)

    else
        error_message = "No .hdf5 file found for " + session_name;
        disp(error_message);
        error_files{end+1} = error_message;
        continue
    end

    % Convert .hdf5 to cleaned .mat file (includes getting spike time
    % matrix, binned spikes, and cleaned pupil data)
    hdf5_fullPath = strcat(base_directory, hdf5_fileName);
    fprintf('Converting .hdf5 to .mat...\n')
    data = new_extractAODR_sessionNeural(hdf5_fullPath, 'MrM', unit_id);

    %% Debugging
    % Check for errors based on what I've encountered before
    % 1. Make sure that there is spike data
    if isempty(data.spikes.data)
        error_message = session_name + " has no spike data in struct created";
        disp(error_message);
        error_files{end+1} = error_message;
        continue
    end

    % 2. Make sure the filename in the header field of the new data
    % structure matches the session name
    if string(data.header.filename) ~= string(hdf5_fullPath)
        error_message = "Current file name " + string(hdf5_fullPath) + ...
            " does not match the filename field in header field of data " + ...
            string(data.header.filename);
        disp(error_message);
        error_files{end+1} = error_message;
        continue
    end

    %% Saving
    % Finally, save cleaned data in a new location
    mat_fullPath = strcat(save_directory, session_name, '.mat');
    save(mat_fullPath, 'data', '-v7.3');
    fprintf('Saved %s as %s\n', session_name, mat_fullPath)
end
    
%% Debugging
% Let user know which files didn't work again
if ~isempty(error_files)
    fprintf('\nFailed to convert and clean the following sessions:\n');
    for file_num = 1:length(error_files)
        fprintf('\n%s\n', string(error_files(file_num)));
    end
end

%% Helper function to convert unit IDs from spreadsheet to double array
function x = convertStringToArray(input_str)

% Remove brackets if present
input_str = strrep(input_str, '[', '');
input_str = strrep(input_str, ']', '');

% Split the string into a cell array of substrings
x_cell = strsplit(input_str, ',');

% Convert the substrings to numbers
x = str2double(x_cell);

end