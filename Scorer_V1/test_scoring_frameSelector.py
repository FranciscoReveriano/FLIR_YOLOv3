import sys
import os
import pickle
import matplotlib.pyplot as plt
import numpy as np
from tqdm import tqdm
from labellines import labelLine, labelLines
from Scorer_V1.python.atlas_scorer.score import Scorer


def epoch0():
    Epoch = "0"
    cur_dir, _ = os.path.split(sys.argv[0])
    # Path of Directory Holding the Declarations
    decl_source_dir = '/home/franciscoAML/Documents/DSIAC/Five_Classes/Version2.0/yolov3/Scores/Test_3/EPOCH_0/DECL'
    # Path of Directory Holding the Truth Declarations
    truth_source_dir = '/home/franciscoAML/Documents/DSIAC/Five_Classes/Version2.0/yolov3/Truth_JSON/'
    # Path of Direction Were we Want the Scores to be stored
    out_dir = '/home/franciscoAML/Documents/DSIAC/Five_Classes/Version2.0/yolov3/Scores/Test_3/EPOCH_0/'

    decl_files = []
    fileName_list = []
    for fileName in os.listdir(decl_source_dir):
        decl_files.append(os.path.join(decl_source_dir,fileName))
        fileName_list.append((fileName))

    truth_files = []
    for name in fileName_list:
        newName = name[:-10] + ".truth.json"
        truth_files.append(os.path.join(truth_source_dir, newName))

    print(decl_files)
    print(truth_files)
    # Some Error Checking
    assert(len(decl_files) == len(truth_files))

    scorer = Scorer()
    scorer.frame_remove_function = lambda i: i % 10 != 1
    scorer.load(truth_files, decl_files)
    scorer.link()
    roc, _ = scorer.aggregate(alg='detection')
    ax = roc.plot_roc(title="ROC Curve", label=Epoch)
    plt.savefig(os.path.join(out_dir, Epoch))
    # Get Axis Handle
    ax2 = plt.gca()
    # Get Line Data
    line = ax2.lines[0]
    # Get X Data
    x = line.get_xdata()
    y = line.get_ydata()
    np.savetxt(os.path.join(out_dir,Epoch+".txt"), (x,y))
    return x , y

def epoch4():
    Epoch = "4"
    cur_dir, _ = os.path.split(sys.argv[0])
    # Path of Directory Holding the Declarations
    decl_source_dir = '/home/franciscoAML/Documents/DSIAC/Five_Classes/Version2.0/yolov3/Scores/Test_3/EPOCH_4/DECL'
    # Path of Directory Holding the Truth Declarations
    truth_source_dir = '/home/franciscoAML/Documents/DSIAC/Five_Classes/Version2.0/yolov3/Truth_JSON/'
    # Path of Direction Were we Want the Scores to be stored
    out_dir = '/home/franciscoAML/Documents/DSIAC/Five_Classes/Version2.0/yolov3/Scores/Test_3/EPOCH_4/'

    decl_files = []
    fileName_list = []
    for fileName in os.listdir(decl_source_dir):
        decl_files.append(os.path.join(decl_source_dir,fileName))
        fileName_list.append((fileName))

    truth_files = []
    for name in fileName_list:
        newName = name[:-10] + ".truth.json"
        truth_files.append(os.path.join(truth_source_dir, newName))

    print(decl_files)
    print(truth_files)
    # Some Error Checking
    assert(len(decl_files) == len(truth_files))

    scorer = Scorer()
    scorer.frame_remove_function = lambda i: i % 10 != 1
    scorer.load(truth_files, decl_files)
    scorer.link()
    roc, _ = scorer.aggregate(alg='detection')
    ax = roc.plot_roc(title="ROC Curve", label=Epoch)
    plt.savefig(os.path.join(out_dir, Epoch))
    # Get Axis Handle
    ax2 = plt.gca()
    # Get Line Data
    line = ax2.lines[0]
    # Get X Data
    x = line.get_xdata()
    y = line.get_ydata()
    np.savetxt(os.path.join(out_dir,Epoch+".txt"), (x,y))
    return x , y

def epoch9():
    Epoch = "9"
    cur_dir, _ = os.path.split(sys.argv[0])
    # Path of Directory Holding the Declarations
    decl_source_dir = '/home/franciscoAML/Documents/DSIAC/Five_Classes/Version2.0/yolov3/Scores/Test_3/EPOCH_' + Epoch+'/DECL'
    # Path of Directory Holding the Truth Declarations
    truth_source_dir = '/home/franciscoAML/Documents/DSIAC/Five_Classes/Version2.0/yolov3/Truth_JSON/'
    # Path of Direction Were we Want the Scores to be stored
    out_dir = '/home/franciscoAML/Documents/DSIAC/Five_Classes/Version2.0/yolov3/Scores/Test_3/EPOCH_' + Epoch + '/'

    decl_files = []
    fileName_list = []
    for fileName in os.listdir(decl_source_dir):
        decl_files.append(os.path.join(decl_source_dir,fileName))
        fileName_list.append((fileName))

    truth_files = []
    for name in fileName_list:
        newName = name[:-10] + ".truth.json"
        truth_files.append(os.path.join(truth_source_dir, newName))

    print(decl_files)
    print(truth_files)
    # Some Error Checking
    assert(len(decl_files) == len(truth_files))

    scorer = Scorer()
    scorer.frame_remove_function = lambda i: i % 10 != 1
    scorer.load(truth_files, decl_files)
    scorer.link()
    roc, _ = scorer.aggregate(alg='detection')
    ax = roc.plot_roc(title="ROC Curve", label=Epoch)
    plt.savefig(os.path.join(out_dir, Epoch))
    # Get Axis Handle
    ax2 = plt.gca()
    # Get Line Data
    line = ax2.lines[0]
    # Get X Data
    x = line.get_xdata()
    y = line.get_ydata()
    np.savetxt(os.path.join(out_dir,Epoch+".txt"), (x,y))
    return x , y

def epoch35():
    Epoch = "35"
    cur_dir, _ = os.path.split(sys.argv[0])
    # Path of Directory Holding the Declarations
    decl_source_dir = '/home/franciscoAML/Documents/DSIAC/Five_Classes/Version2.0/yolov3/Scores/Test_3/EPOCH_' + Epoch+ '/DECL'
    # Path of Directory Holding the Truth Declarations
    truth_source_dir = '/home/franciscoAML/Documents/DSIAC/Five_Classes/Version2.0/yolov3/Truth_JSON/'
    # Path of Direction Were we Want the Scores to be stored
    out_dir = '/home/franciscoAML/Documents/DSIAC/Five_Classes/Version2.0/yolov3/Scores/Test_3/EPOCH_' + Epoch + '/'

    decl_files = []
    fileName_list = []
    for fileName in os.listdir(decl_source_dir):
        decl_files.append(os.path.join(decl_source_dir,fileName))
        fileName_list.append((fileName))
    print(decl_files)
    truth_files = []
    for name in fileName_list:
        newName = name[:-10] + ".truth.json"
        truth_files.append(os.path.join(truth_source_dir, newName))

    print(truth_files)
    # Some Error Checking
    assert(len(decl_files) == len(truth_files))

    scorer = Scorer()
    scorer.frame_remove_function = lambda i: i % 10 != 1
    scorer.load(truth_files, decl_files)
    scorer.link()
    roc, _ = scorer.aggregate(alg='detection')
    ax = roc.plot_roc(title="ROC Curve", label=Epoch)
    plt.savefig(os.path.join(out_dir, Epoch))
    # Get Axis Handle
    ax2 = plt.gca()
    # Get Line Data
    line = ax2.lines[0]
    # Get X Data
    x = line.get_xdata()
    y = line.get_ydata()
    np.savetxt(os.path.join(out_dir,Epoch+".txt"), (x,y))
    return x , y

def epoch30():
    Epoch = "30"
    cur_dir, _ = os.path.split(sys.argv[0])
    # Path of Directory Holding the Declarations
    decl_source_dir = '/home/franciscoAML/Documents/DSIAC/Five_Classes/Version2.0/yolov3/Scores/Test_3/EPOCH_' + Epoch+ '/DECL'
    # Path of Directory Holding the Truth Declarations
    truth_source_dir = '/home/franciscoAML/Documents/DSIAC/Five_Classes/Version2.0/yolov3/Truth_JSON/'
    # Path of Direction Were we Want the Scores to be stored
    out_dir = '/home/franciscoAML/Documents/DSIAC/Five_Classes/Version2.0/yolov3/Scores/Test_3/EPOCH_' + Epoch + '/'

    decl_files = []
    fileName_list = []
    for fileName in os.listdir(decl_source_dir):
        decl_files.append(os.path.join(decl_source_dir,fileName))
        fileName_list.append((fileName))
    print(decl_files)
    truth_files = []
    for name in fileName_list:
        newName = name[:-10] + ".truth.json"
        truth_files.append(os.path.join(truth_source_dir, newName))

    print(truth_files)
    # Some Error Checking
    assert(len(decl_files) == len(truth_files))

    scorer = Scorer()
    scorer.frame_remove_function = lambda i: i % 10 != 1
    scorer.load(truth_files, decl_files)
    scorer.link()
    roc, _ = scorer.aggregate(alg='detection')
    ax = roc.plot_roc(title="ROC Curve", label=Epoch)
    plt.savefig(os.path.join(out_dir, Epoch))
    # Get Axis Handle
    ax2 = plt.gca()
    # Get Line Data
    line = ax2.lines[0]
    # Get X Data
    x = line.get_xdata()
    y = line.get_ydata()
    np.savetxt(os.path.join(out_dir,Epoch+".txt"), (x,y))
    return x , y

def epoch25():
    Epoch = "25"
    cur_dir, _ = os.path.split(sys.argv[0])
    # Path of Directory Holding the Declarations
    decl_source_dir = '/home/franciscoAML/Documents/DSIAC/Five_Classes/Version2.0/yolov3/Scores/Test_3/EPOCH_' + Epoch+ '/DECL'
    # Path of Directory Holding the Truth Declarations
    truth_source_dir = '/home/franciscoAML/Documents/DSIAC/Five_Classes/Version2.0/yolov3/Truth_JSON/'
    # Path of Direction Were we Want the Scores to be stored
    out_dir = '/home/franciscoAML/Documents/DSIAC/Five_Classes/Version2.0/yolov3/Scores/Test_3/EPOCH_' + Epoch + '/'

    decl_files = []
    fileName_list = []
    for fileName in os.listdir(decl_source_dir):
        decl_files.append(os.path.join(decl_source_dir,fileName))
        fileName_list.append((fileName))
    print(decl_files)
    truth_files = []
    for name in fileName_list:
        newName = name[:-10] + ".truth.json"
        truth_files.append(os.path.join(truth_source_dir, newName))

    print(truth_files)
    # Some Error Checking
    assert(len(decl_files) == len(truth_files))

    scorer = Scorer()
    scorer.frame_remove_function = lambda i: i % 10 != 1
    scorer.load(truth_files, decl_files)
    scorer.link()
    roc, _ = scorer.aggregate(alg='detection')
    ax = roc.plot_roc(title="ROC Curve", label=Epoch)
    plt.savefig(os.path.join(out_dir, Epoch))
    # Get Axis Handle
    ax2 = plt.gca()
    # Get Line Data
    line = ax2.lines[0]
    # Get X Data
    x = line.get_xdata()
    y = line.get_ydata()
    np.savetxt(os.path.join(out_dir,Epoch+".txt"), (x,y))
    return x , y

def epoch20():
    Epoch = "20"
    cur_dir, _ = os.path.split(sys.argv[0])
    # Path of Directory Holding the Declarations
    decl_source_dir = '/home/franciscoAML/Documents/DSIAC/Five_Classes/Version2.0/yolov3/Scores/Test_3/EPOCH_' + Epoch+ '/DECL'
    # Path of Directory Holding the Truth Declarations
    truth_source_dir = '/home/franciscoAML/Documents/DSIAC/Five_Classes/Version2.0/yolov3/Truth_JSON/'
    # Path of Direction Were we Want the Scores to be stored
    out_dir = '/home/franciscoAML/Documents/DSIAC/Five_Classes/Version2.0/yolov3/Scores/Test_3/EPOCH_' + Epoch + '/'

    decl_files = []
    fileName_list = []
    for fileName in os.listdir(decl_source_dir):
        decl_files.append(os.path.join(decl_source_dir,fileName))
        fileName_list.append((fileName))
    print(decl_files)
    truth_files = []
    for name in fileName_list:
        newName = name[:-10] + ".truth.json"
        truth_files.append(os.path.join(truth_source_dir, newName))

    print(truth_files)
    # Some Error Checking
    assert(len(decl_files) == len(truth_files))

    scorer = Scorer()
    scorer.frame_remove_function = lambda i: i % 10 != 1
    scorer.load(truth_files, decl_files)
    scorer.link()
    roc, _ = scorer.aggregate(alg='detection')
    ax = roc.plot_roc(title="ROC Curve", label=Epoch)
    plt.savefig(os.path.join(out_dir, Epoch))
    # Get Axis Handle
    ax2 = plt.gca()
    # Get Line Data
    line = ax2.lines[0]
    # Get X Data
    x = line.get_xdata()
    y = line.get_ydata()
    np.savetxt(os.path.join(out_dir,Epoch+".txt"), (x,y))
    return x , y

def epoch15():
    Epoch = "15"
    cur_dir, _ = os.path.split(sys.argv[0])
    # Path of Directory Holding the Declarations
    decl_source_dir = '/home/franciscoAML/Documents/DSIAC/Five_Classes/Version2.0/yolov3/Scores/Test_3/EPOCH_' + Epoch+ '/DECL'
    # Path of Directory Holding the Truth Declarations
    truth_source_dir = '/home/franciscoAML/Documents/DSIAC/Five_Classes/Version2.0/yolov3/Truth_JSON/'
    # Path of Direction Were we Want the Scores to be stored
    out_dir = '/home/franciscoAML/Documents/DSIAC/Five_Classes/Version2.0/yolov3/Scores/Test_3/EPOCH_' + Epoch + '/'

    decl_files = []
    fileName_list = []
    for fileName in os.listdir(decl_source_dir):
        decl_files.append(os.path.join(decl_source_dir,fileName))
        fileName_list.append((fileName))
    print(decl_files)
    truth_files = []
    for name in fileName_list:
        newName = name[:-10] + ".truth.json"
        truth_files.append(os.path.join(truth_source_dir, newName))

    print(truth_files)
    # Some Error Checking
    assert(len(decl_files) == len(truth_files))

    scorer = Scorer()
    scorer.frame_remove_function = lambda i: i % 10 != 1
    scorer.load(truth_files, decl_files)
    scorer.link()
    roc, _ = scorer.aggregate(alg='detection')
    ax = roc.plot_roc(title="ROC Curve", label=Epoch)
    plt.savefig(os.path.join(out_dir, Epoch))
    # Get Axis Handle
    ax2 = plt.gca()
    # Get Line Data
    line = ax2.lines[0]
    # Get X Data
    x = line.get_xdata()
    y = line.get_ydata()
    np.savetxt(os.path.join(out_dir,Epoch+".txt"), (x,y))
    return x , y

def main():
    # Epoch 0
    print("Epoch 0")
    x1,y1 = epoch0()
    print("Epoch 4")
    x4,y4 = epoch4()
    print("Epoch 9")
    x9,y9 = epoch9()
    print("Epoch 15")
    x15,y15 = epoch15()
    print("Epoch 20")
    x20,y20 = epoch20()
    print("Epoch 25")
    x25,y25 = epoch25()
    print("Epoch 30")
    x30,y30 = epoch30()
    print("Epoch 35")
    x35,y35 = epoch35()
    fig = plt.figure()
    ax = plt.subplot(111)
    ax.plot(x1,y1, color="red", Label= "Epoch 0")
    ax.plot(x4,y4, color="blue", Label= "Epoch 4")
    ax.plot(x9,y9, color='green', Label = "Epoch 9")
    ax.plot(x15,y15, color="magenta", Label = "Epoch 15")
    ax.plot(x20,y20, color="black", Label= "Epoch 20")
    ax.plot(x25,y25,color="cyan", Label = "Epoch 25")
    ax.plot(x30,y30, color="orange", Label= "Epoch 30")
    ax.plot(x35,y35, color="pink", Label = "Epoch 35")
    labelLines(plt.gca().get_lines())
    plt.xlabel('$P_{Fa}$')
    plt.ylabel('$P_D$')
    plt.ylim(top=1)
    plt.title("Experiment")
    plt.savefig("/home/franciscoAML/Documents/DSIAC/Five_Classes/Version2.0/yolov3/Scores/Test_3/ROC_Curve_Test3")
    # Second Plot
    fig2 = plt.figure()
    ax2 = plt.subplot(111)
    ax2.plot(x1,y1, color="red", Label= "Epoch 0")
    ax2.plot(x4,y4, color="blue", Label= "Epoch 4")
    ax2.plot(x9,y9, color='green', Label = "Epoch 9")
    ax2.plot(x15,y15, color="magenta", Label = "Epoch 15")
    ax2.plot(x20,y20, color="black", Label= "Epoch 20")
    ax2.plot(x25,y25,color="cyan", Label = "Epoch 25")
    ax2.plot(x30,y30, color="orange", Label= "Epoch 30")
    ax2.plot(x35,y35, color="pink", Label = "Epoch 35")
    ax2.legend()
    plt.xlabel('$P_{Fa}$')
    plt.ylabel('$P_D$')
    plt.ylim(top=1)
    plt.title("Experiment")
    plt.savefig("/home/franciscoAML/Documents/DSIAC/Five_Classes/Version2.0/yolov3/Scores/Test_3/ROC_Curve_Test3_No_Labels")


main()