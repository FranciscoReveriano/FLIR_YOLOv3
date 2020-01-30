import os

def convert_multi_to_single_target():
    '''Converts multi target labels to single target labels'''
    original_folder = 'data/labels_original'
    destination_folder = 'data/labels'
    count = 0
    for filename in os.listdir(original_folder):
        original_txtFile = open(original_folder + '/' + filename,'r')
        line = original_txtFile.readline().split()
        if (len(line) > 0):
            line[0] = 0
        new_txtFile = open(destination_folder + '/' + filename, 'w')
        line = ' '.join([str(elem) for elem in line])
        new_txtFile.write(str(line).strip('[]'))
        count += 1

    print("Total Labels: ", count)

def count_instance_of_targets(num=0):
    '''Counts the number of instances in a single class'''
    original_folder = 'data/labels/train'
    count = 0
    for filename in os.listdir(original_folder):
        original_txtFile = open(original_folder + '/' + filename,'r')
        line = original_txtFile.readline().split()
        if (len(line) > 0):
            if line[0] == str(num):
                count += 1
    print("Instance of class " + str(num) + ": " + str(count))

def count_instance_of_all_classes(num=5):
    '''Counts the number of instances in the whole dataset'''
    for i in range(num):
        count_instance_of_targets(i)


convert_multi_to_single_target()