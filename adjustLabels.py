from tqdm import tqdm
import os

def adjust_labels():
    '''Converts multi target labels to single target labels'''
    original_train = 'data/DSIACPlus_Train.txt'
    original_test = 'data/DSIACPlus_Test.txt'
    trainFileName = "data/DsiacPlusF1.txt"
    validateFileName = "data/DsiacPlusF2.txt"
    # Set Up Training Data Set
    original_train_list = []
    count = 0
    original_txtFile = open(original_train,'r')
    count = 0
    for line in original_txtFile:
        original_train_list.append(line[52:-1])
        count += 1
    print("Total Labels in Train:",count)
    txtFile = open(trainFileName, 'w')
    for i in tqdm(range(len(original_train_list))):
        name = original_train_list[i] + '\n'
        txtFile.write(name)

    # Set Up Testing Data Set
    count = 0
    original_train_list = []
    original_txtFile = open(original_test, 'r')
    count = 0
    for line in original_txtFile:
        original_train_list.append(line[52:-1])
        count += 1
    print("Total Labels in Test:", count)
    txtFile = open(validateFileName, 'w')
    for i in tqdm(range(len(original_train_list))):
        name = original_train_list[i] + '\n'
        txtFile.write(name)

adjust_labels()