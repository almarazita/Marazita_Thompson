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

cleanOutput = set([name.split('.')[0] for name in os.listdir("C:/Users/GoldLab/Box/GoldLab/Data/Physiology/AODR/Data/MrM/Converted/Sorted/Mat_Cleaned/")])

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

cleanConverts = matOutput.intersection(cleanOutput)
print("\n", len(matOutput), "mat-converted Mr. M sessions")
print(len(cleanConverts), "sessions went through cleaning")
cleanFails = matOutput - cleanOutput
print(len(cleanFails), "didn't make it:")
for fail in cleanFails:
    print(fail)

venn = venn2([matOutput, cleanOutput], ("Mat","Cleaned"))
plt.show()