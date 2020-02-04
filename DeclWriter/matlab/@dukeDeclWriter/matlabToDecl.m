function [fileUIDs] = matlabToDecl(self,resultsStructure,declSaveDirectory)
%converts a table of detections into delc files that can be used by CoVar's
%scoring algorithm 
% Input:
% resultsStructure - a MATLAB structure with details about each alarm
% declaration made by a detector
%
% declSaveDirectory - the directory where you wish to write .decl files
%
% Output: 
% fileUIDs - a cell array of the unique video names (not unique frames)
%                in the alarm list.  Note that the main objective of this
%                function is to write .decl files to 'declSaveDirectory'
%

%% write decl.json files
% Convert from MATLAB structure to a MATLAB table
%  (this is to stay consistent with original code)

if ~isempty(resultsStructure)

d = struct2table(resultsStructure);

% d=declcsvTable;
fileUIDs = unique(d.fileUID);

for f=1:length(fileUIDs)
    fileUID=fileUIDs(f);
    cDecls = d(strcmpi(d.fileUID,fileUID{1}),:);
    
    myStruct.declJsonVersion = '0.0.1';
    myStruct.fileUID = fileUID{1};
    myStruct.source = 'det';
    
    frames = cDecls.frameIndex(:);
    uFrames = unique(frames);
    frameDeclarations = [];
    for uFrame = uFrames(:)'
        current = cDecls(frames == uFrame,:);
%         shapeStruct = struct('type', 'bbox_xywh', ...
%             'data', current.shape_bbox_xywh);
        
        nVals = size(current.fileUID,1);
        declsStruct = struct('class', repmat({current.class(1)},[nVals,1]), ...
            'aspect', repmat({current.aspect(1)},[nVals,1]), ...
            'range', repmat({current.range(1)},[nVals,1]), ...
            'confidence', num2cell(current.confidence));
            
            %Insert each bounding box 
            for iAlarm = 1:nVals
                 declsStruct(iAlarm).shape.data = round(current.shape_bbox_xywh(iAlarm,:)');
                 declsStruct(iAlarm).shape.type = 'bbox_xywh';
            end
            
          frameDeclarations.(sprintf('f%d', uFrame)).declarations = declsStruct;
    end
    myStruct.frameDeclarations = frameDeclarations;
    jsonString = jsonencode(myStruct);
    
    tmpFile = sprintf('%s.decl.json', fileUID{1});
    tmpFile = fullfile(declSaveDirectory, tmpFile);
    
    fid = fopen(tmpFile, 'w');
    fprintf(fid,'%s',jsonString);
    fclose(fid);
%     sprintf('File %d of %d finished',f,length(fileUIDs))
end

end


end

