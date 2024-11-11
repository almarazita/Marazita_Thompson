# Check
# 1. Valid sessions made it through pyramid
# 2. Pyramid output made it through MATLAB
# 3. MATLAB output made it through cleaning
import os
import pandas as pd
from matplotlib import pyplot as plt
from matplotlib_venn import venn2

sessionRecord = pd.read_excel("C:/Users/GoldLab/Box/GoldLab/Analysis/AODR/MrM_Ci_Units.xlsx")
sessionNames = [name.split('.')[0] for name in sessionRecord['Name'] if name.startswith('MM')]
sessionNames = set([name.split('_S')[0] for name in sessionNames])

pyramidOutput = [name.split('.')[0] for name in os.listdir("C:/Users/GoldLab/Box/GoldLab/Data/Physiology/AODR/Data/MrM/Converted/Sorted/Pyramid/")]
pyramidOutput = [name.split('_S')[0] for name in pyramidOutput]
pyramidOutput = set([name.split('_s')[0] for name in pyramidOutput])

matOutput = [name.split('.')[0] for name in os.listdir("C:/Users/GoldLab/Box/GoldLab/Data/Physiology/AODR/Data/MrM/Converted/Sorted/Mat/")]
matOutput = [name.split('_S')[0] for name in matOutput]
matOutput = set([name.split('_s')[0] for name in matOutput])

cleanOutput = [name.split('.')[0] for name in os.listdir("C:/Users/GoldLab/Box/GoldLab/Data/Physiology/AODR/Data/MrM/Converted/Sorted/Mat_Cleaned/")]
cleanOutput = set([name.split('_S')[0] for name in cleanOutput])

FIRAcleanOutput = [name.split('.')[0] for name in os.listdir("C:/Users/GoldLab/Box/GoldLab/Analysis/AODR/Cleaned Data/")]
FIRAcleanOutput = [name.split('_Cl')[0] for name in FIRAcleanOutput]
FIRAcleanOutput = [name.split('_S')[0] for name in FIRAcleanOutput]
FIRAcleanOutput = set([name.split('_s')[0] for name in FIRAcleanOutput])

# pyramidConverts = sessionNames.intersection(pyramidOutput)
# print(len(sessionNames), "valid Mr. M sessions")
# print(len(pyramidConverts), "sessions went through Pyramid")
# pyramidFails = sessionNames - pyramidOutput
# print(len(pyramidFails), "didn't make it:")
# for fail in pyramidFails:
#     print(fail)

# venn = venn2([sessionNames, pyramidOutput], ("Excel", "Pyramid"))
# plt.show()

# matConverts = pyramidOutput.intersection(matOutput)
# print("\n", len(pyramidOutput), "pyramid-converted Mr. M sessions")
# print(len(matConverts), "sessions went through .mat conversion")
# matFails = pyramidOutput - matOutput
# print(len(matFails), "didn't make it:")
# for fail in matFails:
#     print(fail)

# venn = venn2([pyramidOutput, matOutput], ("Pyramid", "Mat"))
# plt.show()

# cleanConverts = matOutput.intersection(cleanOutput)
# print("\n", len(matOutput), "mat-converted Mr. M sessions")
# print(len(cleanConverts), "sessions went through cleaning")
# cleanFails = matOutput - cleanOutput
# print(len(cleanFails), "didn't make it:")
# for fail in cleanFails:
#     print(fail)

# venn = venn2([matOutput, cleanOutput], ("Mat","Cleaned"))
# plt.show()

# FIRAcleanConverts = sessionNames.intersection(FIRAcleanOutput)
# print(len(sessionNames), "valid Mr. M sessions")
# print(len(FIRAcleanConverts), "sessions were FRIA-converted and went through cleaning")
# cleanFails = sessionNames - FIRAcleanOutput
# print(len(cleanFails), "didn't make it:")
# for fail in cleanFails:
#     print(fail)

# venn = venn2([sessionNames, FIRAcleanConverts], ("Excel","FIRA Cleaned"))
# plt.show()

# bothConverts = cleanOutput.intersection(FIRAcleanOutput)
# print(len(cleanOutput), "sessions were pyramid-converted and cleaned")
# print(len(FIRAcleanOutput), "sessions were FRIA-converted and cleaned")
# difference = cleanOutput - FIRAcleanOutput
# print(len(difference), "weren't previously cleaned:")
# for fail in difference:
#     print(fail)

# venn = venn2([cleanOutput, FIRAcleanOutput], ("Pyramid Cleaned","FIRA Cleaned"))
# plt.show()