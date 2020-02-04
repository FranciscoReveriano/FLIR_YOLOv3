% Author:  Jordan Malof & Evan Stump
% Institution:  Duke University
% Date:  11/25/2019
% Description:  example script for converting the output of the duke Yolo
%  detector from ultralytics into a .decl file
%
%  EXAMPLE USAGE
%
% %The directory where we would like to write .decl files
% declOutputDirectory ='..<path>\PythonDecls';
% 
% %This is the file location of the output from the detector (a json file).  
% detectorOutputFileLocation = '<path>\dukeDetectorOutput.json';
% 
% %% load python results
% 
% %Instantiate the class that we will use to write .decl files
% dukeS = dukeResultsProcessor();
% 
% % Create a matlab structure with the alarm declaration information
% r = dukeS.rawModelOutputToMatlab(detectorOutputFileLocation);
% 
% % Write the declarations to a directory 'declPath' as a series of 
% % .decl files
% [~] = dukeS.matlabToDecl(r,declOutputDirectory );
%

classdef dukeDeclWriter
    % Converts raw output from the duke detector into a directory of 
    % .decl files. 
    
    properties

    end
    
    methods
            
        %This method converts the raw model output (YoloV3) to a
        %MATLAB-compatible data type
        [resultsStructure] = rawModelOutputToMatlab(self, jsonFile)
        
        %This converts the MATLAB data type into a .decl file set. 
        [fileUIDs] = matlabToDecl(self, resultsStructure, declSavePath);
        
    end
end

