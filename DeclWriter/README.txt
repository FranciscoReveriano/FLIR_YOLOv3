Covar's scoring code for the Atlas Project

#Typical Python Usage: 

import DukeResultsProcessor
detectorOutputLocation = '/home/eas90/PycharmProjects/ATR_Augmentation/yolov3/results.json' # location of yolov3 output file
declOutputDirectory ='/home/eas90/PycharmProjects/ATR_Augmentation/yolov3/data/WrittenDecl/' # directory where decl files will be written
dukeProc = yolo2decl.dukeResultsProcessor()
resultsDict = dukeProc.rawModelOutputToPythonDictionary(detectorOutputLocation)
resultsDict = dukeProc.resultsDictionaryToDecl(resultsDict, declOutputDirectory)
