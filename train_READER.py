'''
Author: Francisco Reveriano
Date: December 18, 2019
Institution: Duke University
Lab: Duke Applied Machine Learning Lab
Inputs: Need to hardcode the pathName for the result .txt Files
Outputs: a .txt file for the Testing and Validation
'''

import os
from tqdm import tqdm

class File_Reader:
    trainPath = ""
    validatePath = ""
    txtPath = ""
    trainFileName = "data/DsiacPlusF1.txt"
    validateFileName = "data/DsiacPlusF2.txt"
    fileList = []
    fileCount = 0
    def __init__(self, trainPath, validatePath, txtPath):
        self.trainPath = trainPath
        self.validatePath = validatePath
        self.txtPath = txtPath
        # Do The Training Directory First
        self.readDirectory(self.trainPath)
        self.writeFile(self.trainFileName)
        # Do the Testing Directory 
        self.fileList = []                      # Here We are clearing out List
        # Do The Validation Directory
        self.readDirectory(self.validatePath)
        self.writeFile(self.validateFileName)
    def Path(self):
        return self.path;
    def readDirectory(self, path):
        assert(path != "" and (len(self.fileList) == 0))
        for filename in os.listdir(path):
            newFilename = path + "/" + filename
            self.fileList.append(newFilename)
            self.fileCount += 1
        print("Files Read: ", self.fileCount)
        print(self.fileList[0])
    def writeFile(self, txtName):
        txtFile = open(txtName, 'w')
        for i in tqdm(range(len(self.fileList))):
            name = self.fileList[i] + '\n'
            txtFile.write(name)

Trainpath = 'data/images/train'
ValidatePath = "data/images/validation"
txtPath = "data/"
reader = File_Reader(Trainpath, ValidatePath, txtPath)
