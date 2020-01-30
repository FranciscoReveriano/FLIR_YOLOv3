'''
 Author: Francisco Reveriano
 Date: 01/15/20
 Purpose: This program counts the frequency of classes
'''

import os
from tqdm import tqdm
import numpy as np

class Frequency_Reader:
    label_path = ''
    fileList = []
    classes = 5
    freqList = np.zeros([5])
    def __init__(self, labelPath):
        self.label_path = labelPath
        self.readDirectory()
        print(self.freqList)
    def readDirectory(self):
        for filename in os.listdir(self.label_path):
            newName = self.label_path+'/'+filename
            txtFile = open(newName, "r")
            for line in txtFile:
                class_type = int(line.split()[0])
                self.freqList[class_type] += 1


# Path of Validation Labels
labelPath = 'data/labels'
reader = Frequency_Reader(labelPath)