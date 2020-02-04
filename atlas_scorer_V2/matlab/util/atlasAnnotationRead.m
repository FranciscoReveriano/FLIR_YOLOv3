function [aTable, aStruct] = atlasAnnotationRead(file, varargin)
% [aTable, aStruct] = atlasAnnotationRead(file)
%   Return a table AND structure array of annotations stored in a
%   .truth.json file.
%   
% [aTable, aStruct] = atlasAnnotationRead(file, 'cacheEnabled', true)
%   Whether to read from a MAT-file cache of the json file.  Default is
%   false.
%
%   atlasAnnotationRead currently supports truthJsonVversion 0.0.1.
%
%   atlasAnnotationRead returns:
%
%       aTable ~ nAnnotations x 7 MATLAB Table object including properites:
%           fileUID, frameIndex, shape, class, tags, range, aspect
%       
%       aStruct ~ 1 x 1 MATLAB structure containing properties:
%   
%       truthJsonVersion, fileUID, startTime, stopTime, nFrames, collection, 
%           staticFov, frameAnnotations
%
%       Note: As of July 18, 2019, in the truth-files we have, the
%       time-zone in stopTime and startTime is known to be wrong; these
%       times are local to the data collection, not in UTC. staticFov
%       is not set properly.
%
%       frameAnnotations is a 1x1 struct, containing properties
%       f<frameIndex>, where frameIndex is a 1-based indexing into the
%       video.  For example:
%
%          aStruct.frameAnnotations.fxxx.annotations
%
%       contains the relevant annotations for the xxx-th frame in the video.
%
%   Note that the table-based-representations of the annotations cannot
%   handle optional/additional features/properties inside annotations.  But
%   this information is available in aStruct.
%       

opts = struct('cacheReadEnabled', false, ...
    'cacheSaveEnabled', false, ...
    'cacheEnabled', []);

% cacheEnabled sets BOTH cacheReadEnabled & cacheSaveEnabled
opts = cvrAssignStringValuePairs(opts, varargin{:});
if ~isempty(opts.cacheEnabled)
    opts.cacheReadEnabled = opts.cacheEnabled;
    opts.cacheSaveEnabled = opts.cacheEnabled;
end

if opts.cacheEnabled
    cacheFile = [file,'.cacheMat.mat'];
    if isfile(cacheFile)
        dRaw = dir(file);
        dCache = dir(cacheFile);
        cacheValid = dRaw.datenum < dCache.datenum;
        if cacheValid
            load(cacheFile, 'aTable', 'aStruct');
            return;
        else 
            [~,f] = fileparts(file);
            fprintf('cacheEnabled, but cache file was invalid for file: %s\n', f);
        end
    end
end

[~,~,e] = fileparts(file);
switch e
    case '.csv'
        error('atlasAnnotationRead cannot read .csv files');
        % [aTable, aStruct] = csvRead(file);
    case '.json'
        [aTable, aStruct] = jsonRead(file);
        aTable.Properties.UserData = struct('nFrames',aStruct.nFrames);
end

tStart = datetime(aStruct.startTime(1:19), ...
    'InputFormat', 'yyyy-MM-dd''T''HH:mm:ss');
tStop = datetime(aStruct.stopTime(1:19), ...
    'InputFormat', 'yyyy-MM-dd''T''HH:mm:ss');

aTable.tStart = repmat(tStart, size(aTable, 1), 1);
aTable.tStop = repmat(tStop, size(aTable, 1), 1);

if opts.cacheSaveEnabled
    save(cacheFile, 'aTable', 'aStruct');
end

end

function [aTable, aStruct] = jsonRead(file)

aStruct = cvrJsonLoad(file);

semver = num2cell(sscanf(aStruct.truthJsonVersion,'%d.%d.%d'));
[major, minor, patch] = deal(semver{:});
assert(major <= 0 & minor <= 0 & patch <= 1);

aFields = fieldnames(aStruct.frameAnnotations);
frameIndices = cellfun(@(c)sscanf(c,'f%d'), aFields);
aAnnotations = {};
for aInd = 1:length(aFields)
    
    if ~isfield(aStruct.frameAnnotations.(aFields{aInd}), 'annotations')
        continue;
    end
    cAnnotations = aStruct.frameAnnotations.(aFields{aInd}).annotations;
    
    % If two annotations in the same frame have different fields, we get a
    % CELL of annotations - handle this by removing inconsistent fields
    % before we try and make a table:
    if iscell(cAnnotations)
        cAnnotations = cvrStructCat(1, cAnnotations{:});
    end
    
    for c = 1:length(cAnnotations)
        cAnnotations(c).frameIndex = frameIndices(aInd);
        cAnnotations(c).fileUID = aStruct.fileUID;
    end
    if aInd == 1
        aAnnotations = repmat({cAnnotations}, length(aFields), 1);
    else
        aAnnotations{aInd} = cAnnotations;
    end
end

[aAnnotations, ~] = cvrStructCat(1, aAnnotations{:});


if isempty(aAnnotations)
    aAnnotations = struct('fileUID', '', ...
        'frameIndex', [], ...
        'shape', struct('type','','data',[]), ...
        'aspect', nan, 'range', nan, 'class', '', 'tags', []);
    aAnnotations = repmat(aAnnotations, 0, 1);
end
aTable = struct2table(aAnnotations, 'AsArray', true);
                
end
