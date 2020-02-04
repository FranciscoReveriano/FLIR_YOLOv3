# -*- coding: utf-8 -*-
"""
Created on Mon Nov  4 19:31:14 2019
@description:  This script contains a Python class that will convert the output 
%  of Duke's trained model (for touchpoint 1) into the .decl file format 
%  required for scoring. Example usage of this python class is provided 
%   below at the bottom of this .py file
@author: Jordan
@organization: Duke University
@contact:  jmmalo03@gmail.com
@date:  2019.12.12  
"""


import json
import os
import numpy as np
import re
import math

#%%

class dukeResultsProcessor:
    #Initialization function
   def __init__(self):
       self.samplingRate=10
       return
       
   def rawModelOutputToPythonDictionary(self,detectorOutputLocation):
        #%%   Input:  
        #  detectorOutputLocation - this is the file location of the output
        #   of our detector (should be a json file location)
        #
        # Output:
        #   r - this is a python dictionary with the alarm information in it
        #         This serves as input to our decl-writer method, also contained 
        #        in this python class
        
        #%  Read the json structure
        with open(detectorOutputLocation, 'r') as f:
            resultsStruct = json.load(f)
            
        # Get image name for every alarm
        imageNames = [ sub['video_name'] for sub in resultsStruct ] 
        
        # This does not maintain order of original list! 
        uniqueImageNames = list(set(imageNames));
        
        # Iterate over alarms from each image
        r = [];
        for v in range(0,len(uniqueImageNames)):
                        
            # Get all alarms from a particular image
            imageResults = [resultsStruct[i] for i in range(0,len(imageNames)) if imageNames[i]==uniqueImageNames[v]];
            
            #Get the name of the video from which the image came
            m = re.search('(.*)_(\d*)', uniqueImageNames[v])
            videoName = m.group(1);
            
            # Correct for the fact that we (Duke) sample only every 
            #   nth frame as defined by self.sampling rate.  And we use matlab indexing when making the
            #      the image indices (starts from 1 instead of 0)
            frameIndex = (self.samplingRate(np.float16(m.group(2))-1))+1;
            
            #%Get all the scores and bounding boxes into cell arrays
            boxesNow = [ sub['bbox'] for sub in imageResults ] 
            scoresNow = [ sub['score'] for sub in imageResults ] 
            
            #% remove the low confidence boxes
    #        boxesNow(scoresNow<.001, :)=[];
    #        scoresNow(scoresNow<.001)=[];
    
    #        % If not empty, add entries to MATLAB structure
            if not scoresNow:
                print('');
                 #%Don't know if I need to put in anything for blanks
    #             r.Boxes{ind} = [];
    #             r.Scores{ind} = 0;
    #             r.Labels{ind} = 'Background';
            else:
                for ind in range(0,len(scoresNow)):
                    inputTemp = {'fileUID': videoName,  \
                                 'frameIndex': frameIndex, \
                                 'source': 'det', \
                                 'class': '', \
                                 'confidence': scoresNow[ind], \
                                 'aspect':math.nan, \
                                 'range':math.nan, \
                                 'shape_bbox_xywh':boxesNow[ind]};
                                 
                    r.append(inputTemp);
            #print(v)
        print('Finished writing results file')
        return r; 


   def resultsDictionaryToDecl(self,resultsDict,declOutputDirectory):
        #%%   Input:  
        #  resultsDictionary - This is a python dictionary that contains the
        #    information about each alarm made by the detector.  This is 
        #    typically returned by the 'rawModelOutputToPythonDictionary' 
        #    method in this class
        # 
        #  declOutputDirectory - this is the directory where you would like to 
        #     write the decl files.  
        #
        # Output:
        #   This script write decl files, one for each 'arf' video, into the
        #   'declOutputDirectory' directory
       
               # Get the unique video file names
        videoNames = [ sub['fileUID'] for sub in resultsDict];
        videoNamesUnique = list(set(videoNames));       
        
    
        #%%  Iterate over videos - write one decl file for each video
        for v in range(0,len(videoNamesUnique)):
#        for v in range(0,1):
            
            #
            #Write decl file header 
            declDictionary = {'declJsonVersion':'0.0.1', \
                          'fileUID': videoNamesUnique[v], \
                              'source':'det',\
                              'frameDeclarations': None};
                   
            #Get all alarms associated with this video
            alarmsInVideo = [resultsDict[i] for i in range(0,len(videoNames)) if resultsDict[i]['fileUID']==videoNamesUnique[v]];    
            alarmFrames = [ sub['frameIndex'] for sub in alarmsInVideo];
            alarmFramesUnique = list(set(alarmFrames));       
           
            #%%  ITERATE OVER EACH FROM OF THE VIDEO
            frameDictionary = {};
            for uFrame in alarmFramesUnique: #range(0,len(alarmFramesUnique)):
                
                #Get all alarms for this particular frame
                alarmsInFrame = [alarmsInVideo[iFrame] for iFrame in range(0,len(alarmFrames)) if alarmsInVideo[iFrame]['frameIndex']==uFrame];
                
                #Now we need a list of dictionaries - one dictionary for each alarm
                alarmList = [];
                
                for alarmNow in alarmsInFrame:
                    singleAlarmDict = {'class':'',  \
                                 'aspect': None,  \
                                 'range' : None,  \
                                 'confidence': alarmNow['confidence'], \
                                 'shape' : None};
                        
                    # For each frame of the video, write a dictionary including all alarms
                    singleAlarmShapeDict = {'data': alarmNow['shape_bbox_xywh'], \
                                     'type':'bbox_xywh'}
                    
                    # Add shape dictionary into the alarm dictionary
                    singleAlarmDict['shape'] = singleAlarmShapeDict;
                   
                    # Append the alarm onto the existing list
                    alarmList.append(singleAlarmDict);
            
                        
                #Input this array into 
                frameDictionary['f' + str(int(uFrame))] = {'declarations':alarmList};
                
                #Put frameDictionary back into declDictionary
                declDictionary['frameDeclarations'] = frameDictionary;
                
            
            #%% Write decl file
            declNameNow = os.path.join(declOutputDirectory,videoNamesUnique[v] + '.decl.json')
            
            # Check if a decl file exists already (by default, delete it)
            if os.path.exists(declNameNow):
                print('overwriting existing decl with same name')
                os.remove(declNameNow)
            
            #WRite decle file
            with open(declNameNow, 'w') as f:
                json.dump(declDictionary,f);
                
            print('Video Decl ' + str(v) + ' is finished');

       
       
        return;
        
#%% 


if __name__ == "__main__":
    
    
    # Print statement
    print('Example usage for writing decl files');
    
    #%% SPECIFY FILE LOCATIONS
      
    #%This is the file location of the output from the detector (a json file).  
    detectorOutputLocation = '/home/evanaml/PycharmProjects/ATR/yolov3/results.json'

    #%The directory where we would like to write .decl files
    declOutputDirectory ='/home/evanaml/PycharmProjects/ATR/yolov3/data/WrittenDecl/'

    #%%  Instantiate decl-writer class
    dukeProc = dukeResultsProcessor()
    
    #%%  Get results dictionary
    resultsDict = dukeProc.rawModelOutputToPythonDictionary(detectorOutputLocation)
    
    #%%  WRite decl files
    resultsDict = dukeProc.resultsDictionaryToDecl(resultsDict,declOutputDirectory)
    
    