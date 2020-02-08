from DeclWriter.python.yoloOutputToDecl_v2 import dukeResultsProcessor

detectorOutputLocation = '/home/franciscoAML/Documents/DSIAC/Five_Classes/Version2.0/yolov3/JSON/Test15_results.json' # location of yolov3 output file
declOutputDirectory ='/home/franciscoAML/Documents/DSIAC/Five_Classes/Version2.0/yolov3/WrittenDecl/' # directory where decl files will be written
dukeProc = dukeResultsProcessor()
resultsDict = dukeProc.rawModelOutputToPythonDictionary(detectorOutputLocation)
resultsDict = dukeProc.resultsDictionaryToDecl(resultsDict, declOutputDirectory)