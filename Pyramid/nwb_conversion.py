from datetime import datetime
from zoneinfo import ZoneInfo
from pathlib import Path
from neuroconv.datainterfaces import PlexonSortingInterface

import os

# Directory where the sorted plexon data files are stored
dataSearchPath = "C:/Users/GoldLab/Box/GoldLab/Data/Physiology/AODR/Data/MrM/Sorted/Plexon-sorted/"
baseSaveDir = "C:/Users/GoldLab/Box/GoldLab/Data/Physiology/AODR/Data/MrM/Converted/Sorted/nwb/"

# Keep only the most recently sorted version of each session
filenames = os.listdir(dataSearchPath)
final_filenames = []
i = 0
# For each valid filename
while i < len(filenames):
    
    # Get its name except the last digit and extension
    cur_file_base = filenames[i][:-5]

    # If there's at least one file left to check, and the next file is a newer version
    while i < len(filenames)-1 and filenames[i+1][:-5] == cur_file_base:
        # Keep going
        i += 1
    # Now whatever is at position i is most recent, so save it
    final_filenames.append(filenames[i])

    # Increment
    i += 1

# For each Plexon file in dataSearchPath
for filename in final_filenames:

    print("\n", filename)
    f = os.path.join(dataSearchPath, filename)
    outputFname = baseSaveDir+os.path.splitext(filename)[0]+".nwb"

    file_path = f
    # Change the file_path to the location in your system
    interface = PlexonSortingInterface(file_path=file_path, verbose=True)

    # Extract what metadata we can from the source files
    metadata = interface.get_metadata()
    # For data provenance we add the time zone information to the conversion
    session_start_time = metadata["NWBFile"]["session_start_time"].replace(tzinfo=ZoneInfo("US/Pacific"))
    metadata["NWBFile"].update(session_start_time=session_start_time)

    # Choose a path for saving the nwb file and run the conversion
    nwbfile_path = f"{outputFname}"
    interface.run_conversion(nwbfile_path=nwbfile_path, metadata=metadata, overwrite=True)