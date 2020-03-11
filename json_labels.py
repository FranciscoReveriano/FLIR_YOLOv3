import json
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
import pandas as pd

def get_statistics_of_json(filename):
    # Open the JSON File
    with open(filename,"r") as read_file:
        data = json.load(read_file)

    print("Total Annotations:", len(data["annotations"]))

    # Read the File
    count_people = 0
    count_bicycles = 0
    count_cars = 0
    count_dogs = 0
    for category in data["annotations"]:
        #print(category["image_id"], category["category_id"], category["bbox"])
        if category["category_id"] == 1:
            count_people += 1
        if category["category_id"] == 2:
            count_bicycles += 1
        if category["category_id"] == 3:
            count_cars += 1
        if category["category_id"] == 17:
            count_dogs += 1

    # Print the Distribution
    print("People:", count_people)
    print("Bicycles:", count_bicycles)
    print("Cars:", count_cars)
    print("Dogs:", count_dogs)

    # Make the Plot
    frame = pd.DataFrame({'Classes':['People', "Bicycle", "Car", "Dog"],
                          "Size":[count_people, count_bicycles, count_cars, count_dogs]}).sort_values(by="Size")
    sns.set(style="whitegrid")
    sns.barplot(x= "Classes", y="Size", data=frame)
    plt.title("Distribution of Testing Classes")
    plt.xlabel("Class")
    plt.ylabel("Number of Annotations")
    plt.savefig("Testing_Distribution")


def get_category_info(category):
    file_path = "FLIR_" + str(category["image_id"])
    # Convert BBOX into String
    new_box = ""
    box = category["bbox"]
    for item in box:
        new_box = new_box + " " + str(item)
    # Prepare String to Be Printed
    file_info = str(category["category_id"]) + " " + new_box
    # print(file_path + " " + file_info)
    return file_info

def image_name(filename):
    category = len(str(filename))
    correct_filename = ""
    if category == 1:
        if filename == 9:
            correct_filename = "000" + str(filename + 1)
        else:
            correct_filename = "0000" + str(filename + 1)
    if category == 2:
        if filename == 99:
            correct_filename = "00" + str(filename + 1)
        else:
            correct_filename = "000" + str(filename + 1)
    if category == 3:
        if filename == 999:
            correct_filename = "0" + str(filename + 1)
        else:
            correct_filename = "00" + str(filename + 1)
    if category == 4:
        if filename == 9999:
            correct_filename = str(filename + 1)
        else:
            correct_filename = "0" + str(filename + 1)
    return correct_filename


def image_name_val(filename):
    filename += 8863
    category = str(filename)
    if len(category) == 4:
        correct_name = "0" + str(category)
    else:
        correct_name = str(category)
    return correct_name


def convert_labels(filename):
    # Open the JSON File
    with open(filename,"r") as read_file:
        data = json.load(read_file)

    # Combine by Images
    List_Images = []
    for category in data["annotations"]:
        image_id = category["image_id"]
        file_name_txt = "Annotations/val/FLIR_" + image_name_val(image_id) + ".txt"
        info = get_category_info(category)
        with open(file_name_txt, 'a') as f:
            f.write(str(info) + "\n")


train_json = "/home/franciscoAML/Documents/DSIAC/DSIAC/FLIR/yolov3/data/train_thermal_annotations.json"
test_json = "/home/franciscoAML/Documents/DSIAC/DSIAC/FLIR/yolov3/data/val_thermal_annotations.json"
convert_labels(test_json)