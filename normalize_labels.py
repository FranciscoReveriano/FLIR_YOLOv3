import os
import cv2
from tqdm import tqdm

class Normalizer:
    Annotations_path = ""
    Image_path = ""
    File_Name_List = []
    New_Annotations_path = ""
    Num_Annotations = 0
    New_Num_annotations = 0
    def __init__(self, Train_Path, Image_Path, Annotation_Path):
        self.Annotations_path = Train_Path                                                                              # Path of Annotations
        self.Image_path = Image_Path                                                                                    # Path of Images Located
        self.New_Annotations_path = Annotation_Path
        # First We Count How Many Annotations There Are
        self.count_annotations()
        # We Proceed to Normalize The Images
        self.normalization()
        # Proceed To Count How Many New Annotations we made
        self.recount_annotations()
        # Make Sure We Made All the correct Annotations
        assert(self.Num_Annotations == self.New_Num_annotations)
    def count_annotations(self):
        count = 0
        for file in os.listdir(self.Annotations_path):
            count += 1
            self.File_Name_List.append(file)
        print("Total Annotations Count:", count)
        self.Num_Annotations = count
    def normalize_line(self,line,imSize1,imSize2):
        line = line.split()
        object_class, target1, target2, target3, target4 = int(line[0]), float(line[1]), float(line[2]), float(line[3]), float(line[4])
        xC = target1 + target3/2
        yC = target2 + target4/2
        newBox1 = (xC - 1)/imSize2
        newBox2 = (yC - 1)/imSize1
        # Catch the OutofBound
        if newBox1 > 1:
            newBox1 = 1
        elif newBox1 < 0:
            newBox1 = 0
        if newBox2 > 1:
            newBox2 = 1
        elif newBox2 < 0:
            newBox2 = 0
        # Conduct Changes on Object Clas
        if int(object_class) == 1:
            object_class = 0
        if int(object_class) == 2:
            object_class = 1
        if int(object_class) == 3:
            object_class = 2
        if int(object_class) == 17:
            object_class = 3
        # Calculate Remaining Boxes
        newBox3 = target3/imSize2
        newBox4 = target4/imSize1
        new_line = str(object_class) + " " + str(newBox1) + " " + str(newBox2) + " " + str(newBox3) + " " + str(newBox4)
        return new_line

    def normalization(self):
        for file in tqdm(self.File_Name_List):
            annotation_path_name = self.Annotations_path + "/" + file                                                   # Label Path name
            image_path_name = self.Image_path + "/" + file[:-4] + ".jpeg"                                               # Image Path Name
            f = open(annotation_path_name, "r")
            lines = f.readlines()
            for line in lines:
                image = cv2.imread(image_path_name)
                imSize1, imsize2 = image.shape[0], image.shape[1]
                new_line = self.normalize_line(line, imSize1, imsize2)
                file_name_txt = self.New_Annotations_path + file
                with open(file_name_txt, 'a') as f:
                    f.write(str(new_line) + "\n")
    def recount_annotations(self):
        count = 0
        for file in os.listdir(self.New_Annotations_path):
            count += 1
        print("\nTotal Annotations Made:", count)
        self.New_Num_annotations = count

# Path of the Train
#Labels_Train_Path = "Annotations/train"                                                                                   # Were Training Labels are At
#Images_Train_Path = "data/images/train"                                                                                   # Image Location
#AnnotationPath = "Normalized_Annotations/train/"                                                                          # Were to Play New Annotations
#Normalizer(Labels_Train_Path, Images_Train_Path, AnnotationPath)

# For Validation
Labels_Train_Path = "Annotations/val"                                                                                   # Were Training Labels are At
Images_Train_Path = "data/images/val"                                                                                   # Image Location
AnnotationPath = "Normalized_Annotations/val/"                                                                          # Were to Play New Annotations
Normalizer(Labels_Train_Path, Images_Train_Path, AnnotationPath)
