# In some cases, we used linear electrode arrays where an automatic sorting routine might be better suited.
# For the dlPFC recordings in Monkey MrM, an S-Probe was utilized and Kilsort 3. The spike output is therefore saved as a phy file.
# In this case we need 2 file "readers"
# 1) A version of the plexon file with event and eye data
# 2) A phy folder with the spike-sorted data

# Print file info?
debugging = False

from pyramid import cli
import pandas as pd
import os, sys
from matplotlib import pyplot as plt
from matplotlib_venn import venn2, venn3

# Directory where the sorted plexon data files are stored
#dataSearchPath = "C:/Users/GoldLab/Box/GoldLab/Data/Physiology/AODR/Data/MrM/Sorted/"
dataSearchPath = "C:/Users/GoldLab/Box/GoldLab/Data/Physiology/AODR/Data/MrM/Raw/"
# Directory where pyramid can find your ecode rules
pyramidSearchPath = "C:/Users/GoldLab/OneDrive/Documents/GitHub/Lab_Pipelines/experiments/aodr/ecodes/"
# Directory of Phy folders
phySearchPath = "C:/Users/GoldLab/Box/GoldLab/Data/Physiology/AODR/Data/MrM/Sorted/Phy folders/"
# Conversion specifications
convertSpecs = "C:/Users/GoldLab/OneDrive/Documents/GitHub/Lab_Pipelines/lwthompson2/experiments/aodr/AODR_plex_phy_experiment.yaml"
# Base directory to save the output files from pyramid (hdf5 files)
baseSaveDir = "C:/Users/GoldLab/Box/GoldLab/Data/Physiology/AODR/Data/MrM/Converted/Sorted/Pyramid/"
sys.path.append("C:/Users/GoldLab/OneDrive/Documents/GitHub/Lab_Pipelines/lwthompson2/experiments/aodr/python") # to make sure pyramid can access the custom collectors/enhancers/functions?

# Debugging
excel_phy_filenames = ["MM_2022_03_18_6_96.plx", "MM_2022_03_23_6_58.plx", "MM_2022_09_14_REC2V.plx",
                       "MM_2022_09_26B_RECV.plx", "MM_2022_10_05_Rec.plx", "MM_2022_10_07_Rec.plx",
                       "MM_2022_10_27_Rec.plx", "MM_2022_11_02B_V-ProRec.plx", "MM_2022_11_04_V-ProRec.plx",
                       "MM_2022_11_04b_V-ProRec.plx", "MM_2022_11_28C_V-ProRec.plx", "MM_2022_11_30_BV-ProRec.plx",
                       "MM_2022_12_07_BV-ProRec.plx", "MM_2022_12_07_V-ProRec.plx", "MM_2022_12_12_BV-ProRec.plx",
                       "MM_2022_12_12_CV-ProRec.plx", "MM_2023_01_05_ZV-ProRec.plx", "MM_2023_01_09_VV-ProRec.plx",
                       "MM_2023_01_23_BV-ProRec.plx", "MM_2023_01_30_BV-ProRec.plx", "MM_2023_01_30_V-ProRec.plx",
                       "MM_2023_08_14C_Rec_V-ProRec.plx", "MM_2023_08_15_Rec_V-ProRec.plx",
                       "MM_2023_08_15C_Rec_V-ProRec.plx", "MM_2023_08_16_Rec_V-ProRec.plx", "MM_2023_08_16B_Rec_V-ProRec.plx",
                       "MM_2023_08_18_Rec_V-ProRec.plx", "MM_2023_08_21_Rec_V-ProRec.plx", "MM_2023_08_21B_Rec_V-ProRec.plx",
                       "MM_2023_08_21C_Rec_V-ProRec.plx", "MM_2023_08_23c_Rec_V-ProRec.plx", "MM_2023_08_28B_Rec_V-ProRec.plx",
                       "MM_2023_08_28C_Rec_V-ProRec.plx", "MM_2023_08_29_Rec_V-ProRec.plx", "MM_2023_08_29C_Rec_V-ProRec.plx",
                       "MM_2023_08_30_Rec_V-ProRec.plx", "MM_2023_08_30C_Rec_V-ProRec.plx", "MM_2023_09_05B_Rec_V-ProRec.plx",
                       "MM_2023_09_06C_Rec_V-ProRec.plx", "MM_2023_09_08_Rec_V-ProRec.plx"]
excel_phy_filenames = set([name.split('.')[0] for name in excel_phy_filenames])
sorted_plx_filenames = set([s.split('.')[0] for s in os.listdir(dataSearchPath) if s.endswith(".plx")])
sorted_plx_filenames_2 = []
for name in sorted_plx_filenames:
    new_name = name.split('_S')[0]
    new_name = new_name.split('-S')[0]
    new_name = new_name.split('_s')[0]
    new_name = new_name.split('-0')[0]
    sorted_plx_filenames_2.append(new_name)
sorted_plx_filenames_2 = set(sorted_plx_filenames_2)
phy_folder_names = set([name.split('_s')[0] for name in os.listdir(phySearchPath)])

all_data = (excel_phy_filenames.intersection(sorted_plx_filenames_2)).intersection(phy_folder_names)

if debugging:

    venn = venn3([excel_phy_filenames, sorted_plx_filenames_2, phy_folder_names], ("Sessions in Excel with Phy IDs",
                                                                                "Sessions with .plx file in Sorted folder",
                                                                                "Sessions with a phy folder"))
    plt.show()

    excel_no_plx = excel_phy_filenames - sorted_plx_filenames_2 # Names in spreadsheet but not data search path (no .plx)
    excel_no_phy_folder = excel_phy_filenames - phy_folder_names # Names in spreadsheet but not phy folder list
    plx_no_phy_folder = sorted_plx_filenames_2 - phy_folder_names # Names in data search path but not phy folder list
    phy_no_plx = phy_folder_names - sorted_plx_filenames_2 # Names in phy folder list but not data search path

    excel_only = excel_no_plx.intersection(excel_no_phy_folder) # Names in spreadsheet that have neither .plx nor phy files
    plx_only = plx_no_phy_folder - excel_phy_filenames # Names in data search path (have .plx) but in neither spreadsheet nor phy folder
    phy_only = phy_no_plx - excel_phy_filenames # Names in phy folders but in neither spreadsheet nor data search path (no .plx)

    excel_plx = excel_no_phy_folder - excel_no_plx # Names in spreadsheet that have .plx but not phy files
    excel_phy = excel_no_plx - excel_no_phy_folder # Names in spreadsheet that have phy files but not .plx
    plx_phy = sorted_plx_filenames_2.intersection(phy_folder_names) - excel_phy_filenames # Names in .plx and phy but not spreadsheet

    print("The spreadsheet indicates", len(excel_phy_filenames), "valid, Mr. M, kilsorted sessions")
    print("There are", len(sorted_plx_filenames_2), ".plx files in the Sorted folder")
    print("There are", len(phy_folder_names), "folders in the Phy folders folder\n")

    print(len(excel_only), "in Excel ONLY:")
    for name in excel_only:
        print(name)
    print("\n")

    print(len(plx_only), "in Sorted folder ONLY:")
    for name in plx_only:
        print(name)
    print("\n")

    print(len(phy_only), "in Phy Folders ONLY:")
    for name in phy_only:
        print(name)
    print("\n")

    print(len(excel_plx), "in Excel and Sorted:")
    for name in excel_plx:
        print(name)
    print("\n")

    print(len(excel_phy), "in Excel and Phy:")
    for name in excel_phy:
        print(name)
    print("\n")

    print(len(plx_phy), "in Sorted and Phy:")
    for name in plx_phy:
        print(name)
    print("\n")

    print(len(all_data), "in Excel, Sorted, and Phy:")
    for name in all_data:
        print(name)
    print("\n")


# For each Kilosorted session in the Excel sheet with a .plx file and phy folder
plexon_names = [filename for filename in os.listdir(dataSearchPath) if filename.endswith(".plx")]
phy_names = os.listdir(phySearchPath)

empty_spikes = ["MM_2023_08_29C_Rec_V-ProRec", "MM_2023_08_30C_Rec_V-ProRec", "MM_2023_08_29_Rec_V-ProRec"]

for baseName in all_data:

    if baseName in empty_spikes:
        print("\n", baseName)

        # Name of the current Plexon file
        currentPlx = [filename for filename in plexon_names if baseName in filename]
        # Some sessions were re-saved. Allow the user to choose which to use.
        if len(currentPlx) > 0:
            print("Multiple matching Plexon files")
            currentPlx = currentPlx[1]
        else:
            currentPlx = currentPlx[0]
        print("currentPlx =", currentPlx)

        # Name of the phy folder containing the params.py file
        phyFolder = phySearchPath+[filename for filename in phy_names if baseName in filename][0]+"/phy/params.py"
        print("phyFolder =", phyFolder)

        # The name you'd like for the .hdf5 output file
        outputFname = baseSaveDir+currentPlx.split('.')[0]+".hdf5"
        print("outputFname =", outputFname)

        # Run the file through pyramid
        cli.main(["convert", 
                "--trial-file", outputFname, 
                "--search-path", pyramidSearchPath, 
                "--experiment", convertSpecs, 
                "--readers", 
                "plexon_reader.plx_file="+dataSearchPath+currentPlx,
                "phy_reader.params_file="+phyFolder])

