% Anubis example behavior
% Run Pyramid_Example_OE.py to convert your session, then convert it to
% matlab "dataSession" format. Then examine the eye data.
trial_file_path =  '/Users/lowell/Library/CloudStorage/Box-Box/GoldLab/Data/Physiology/AODR/Data/Anubis/Converted/Behavior/Pyramid/Anubis_2025-01-24_12-24-47.hdf5';
[pyramid_fits, pyramid_data] = plotAODR_sessionBehavior( ...
        'filename', trial_file_path, ...
        'monkey', 'Anubis',...
        'forceConvert',true);

cleaned_data = extractAODR_sessionNeural(trial_file_path, 'Anubis', []);

plotEye(cleaned_data)
get_pupil_change({cleaned_data}, 1, 0)
plot_pupil({cleaned_data}, 1, "bs", 0)