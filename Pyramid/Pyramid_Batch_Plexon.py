from pyramid import cli
import pandas as pd
import os, sys

# Directory where the sorted plexon data files are stored
dataSearchPath = "C:/Users/GoldLab/Box/GoldLab/Data/Physiology/AODR/Data/MrM/Sorted/Plexon-sorted/"
pyramidSearchPath = "C:/Users/GoldLab/OneDrive/Documents/GitHub/Lab_Pipelines/lwthompson2/experiments/aodr/ecodes/"
# Conversion specifications
convertSpecs = "C:/Users/GoldLab/OneDrive/Documents/GitHub/Marazita_Thompson/AODR_plex_experiment.yaml"
# Base directory to save the output files from pyramid (hdf5 files)
baseSaveDir = "C:/Users/GoldLab/Box/GoldLab/Data/Physiology/AODR/Data/MrM/Converted/Sorted/Pyramid/"
sys.path.append("C:/Users/GoldLab/OneDrive/Documents/GitHub/Lab_Pipelines/lwthompson2/experiments/aodr/python") # to make sure pyramid can access the custom collectors/enhancers/functions?

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

print(len(final_filenames), "valid, Plexon-sorted, and non-duplicate files out of", len(filenames), "in directory")

# Re-do sessions that didn't work
#KeyError_redos = ["MM_2023_07_14_D_Rec_V-ProRec_Sorted-01.plx", "MM_2023_07_12_B_Rec_V-ProRec_Sorted-03.plx",
 #                 "MM_2023_07_19_Rec_V-ProRec_Sorted-01.plx", "MM_2023_07_17_G_Rec_V-ProRec_Sorted-01.plx",
  #                "MM_2023_07_18_B_Rec_V-ProRec_Sorted-01.plx"]
#working_examples = ["MM_2021_07_15_Sorted-03.plx", "MM_2021_08_04_Sorted-01.plx"]

# For each Plexon file in dataSearchPath
for filename in final_filenames:

    #if filename in KeyError_redos:
    #if filename in working_examples:

    print("\n", filename)
    f = os.path.join(dataSearchPath, filename)
    outputFname = baseSaveDir+os.path.splitext(filename)[0]+".hdf5"
    cli.main(["convert", 
    "--trial-file", outputFname, 
    "--search-path", pyramidSearchPath, 
    "--experiment", convertSpecs, 
    "--readers", 
    "plexon_reader.plx_file="+dataSearchPath+filename])