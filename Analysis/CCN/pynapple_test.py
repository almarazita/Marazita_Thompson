import pynapple as nap
from matplotlib import pyplot as plt
#import workshop_utils
import numpy as np

#path = workshop_utils.fetch_data("Mouse32-140822.nwb")
path = "C:/Users/GoldLab/Box/GoldLab/Data/Physiology/AODR/Data/MrM/Converted/Sorted/nwb/MM_2021_07_15_Sorted-03.nwb"

print(path)

data = nap.load_file(path)

print(data)

spikes = data["units"]  # Get spike timings

print(spikes)