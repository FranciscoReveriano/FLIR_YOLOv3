%Description:  
%  MATLAB script that converts a json file from the duke detector into 
%  a matlab structure, for easier handling later. 
%
%Input
% 'pyJSON':  
%The location of the json file returned by the duke detector script (i.e., after you run test.py)
%
%Output:
% 'r': 
%The MATLAB struct 'r', which contains the details of each detection declaration made by the algorithm. 

function [r] = rawModelOutputToMatlab(self, pyJSON)

% Convert the json file to a MATLAB structure
pythonresults=jsondecode(fileread(pyJSON));

% Get the image name for each alarm declaration
%imageNames = {pythonresults(:).video_name};
imageNames = {pythonresults(:).videoName};
% Get the unique image names across all alarm declaration
uniqueImageNames=unique(imageNames);

%% PULL OUT declarion details and reformat them
% Iterate over each unique image.  For 
r(length(imageNames)).class = "";
count = 1;
for v=1:length(uniqueImageNames)
        %Get all detections associated with a particular *image*
        imageResults=pythonresults(strcmp(imageNames, uniqueImageNames{v} ));
        % Get the unique name from which the video came from. 
        [myMatch,myToken]=regexp(uniqueImageNames{v}, '(.*)_(\d*)', 'Match','tokens');
        videoName = myToken{1}{1};
        frameIndex = (10*(str2double(myToken{1}{2})-1))+1;
        
        %Get all the scores and bounding boxes into cell arrays
        boxesNow=vertcat([imageResults(:).bbox]');
        scoresNow=vertcat(imageResults(:).score);
        boxesNow(scoresNow<.001, :)=[];
        scoresNow(scoresNow<.001)=[];

        % If not empty, add entries to MATLAB structure
        if ~isempty(scoresNow)
            for ind = 1:length(scoresNow)
                 r(count).fileUID =(videoName);
                 r(count).frameIndex = frameIndex;
                 r(count).source=('det');
                 r(count).class="";
                 r(count).confidence=scoresNow(ind);
                 r(count).aspect=NaN;
                 r(count).range=NaN;
                 r(count).shape_bbox_xywh=(boxesNow(ind,:));
                 
                 %Increment overall index
                count = count+1;
            end
        else 
            %Don't know if I need to put in anything for blanks
%             results.Boxes{ind} = [];
%             results.Scores{ind} = 0;
%             results.Labels{ind} = 'Background';
        end

end 


end



