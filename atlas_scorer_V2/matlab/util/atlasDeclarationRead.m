function [dTable, dStruct] = atlasDeclarationRead(file)
% [dTable, dStruct] = atlasDeclarationCsvRead(file)
%   Return a table AND structure array of declarations stored in the
%   .decl.CSV or .decl.JSON file.
%
%

[~,~,e] = fileparts(file);
switch e
    case '.csv'
        [dTable, dStruct] = csvRead(file);
    case '.json'
        [dTable, dStruct] = jsonRead(file);
end

end

function [dTable, dStruct] = jsonRead(file)

dStruct = cvrJsonLoad(file);
dFields = fieldnames(dStruct.frameDeclarations);
frameIndices = cellfun(@(c)sscanf(c,'f%d'), dFields);

allDeclarations = cell(length(dFields), 1);
for dInd = 1:length(dFields)
    
    if ~isfield(dStruct.frameDeclarations.(dFields{dInd}), 'declarations')
        % Technically this is easy to handle; we can just ignore this
        % frame, but for now this indicates an error
        error(['All frame dictionaries must contain a declarations ',...
            'array, even if empty']);
    end
    cDeclarations = dStruct.frameDeclarations.(dFields{dInd}).declarations;
    if iscell(cDeclarations)
        % If one frame contains two declarations, they must both contain
        % the same optional fields, e.g., if one has "aspect", the other
        % declaration must also have aspect, otherwise the response is a
        % CELL, and we have no good way to merge the cells.  We can
        % eventually handle this by moving some logic from below into a
        % special case to handle cells. But we'll need to change the way we
        % grow "allDeclarations".
        error(['All declarations in file %s must have the same fields ',...
            '(frame %d)'], file, frameIndices(dInd));
    end
    
    for c = 1:length(cDeclarations)
        cDeclarations(c).frameIndex = frameIndices(dInd);
        cDeclarations(c).fileUID = dStruct.fileUID;
    end
    allDeclarations{dInd} = cDeclarations;
end

aDeclarations = cat(1, allDeclarations{:});
for i = 1:length(aDeclarations)
    if ~isfield(aDeclarations(i),'range') || isempty(aDeclarations(i).range)
        aDeclarations(i).range = nan;
    end
    if ~isfield(aDeclarations(i),'aspect') || isempty(aDeclarations(i).aspect)
        aDeclarations(i).aspect = nan;
    end
end

if isempty(aDeclarations)
    dTable = table();
    return
end

dTable = struct2table(aDeclarations, 'AsArray', true);
dTable.source = repmat({dStruct.source}, size(dTable, 1), 1);
end


function [dTable, dStruct] = csvRead(file)
dTable = readtable(file);

% This is *way* faster than iterationg over the entries with str2num:
boxStr = sprintf('%s ', dTable.shape_bbox_xywh{:});
boxStr = strrep(boxStr, '[]', '[nan nan nan nan]');
boxStr = strrep(boxStr,']',' ');
boxStr = strrep(boxStr,'[',' ');
x = sscanf(boxStr, '%f');
x = reshape(x, 4, []);

% Make the 4 x n matrix into the n x 1 cell, and put it in the table:
dTable.shape_bbox_xywh = num2cell(x', 2);
if isnumeric(dTable.class) && all(isnan(dTable.class))
    dTable.class = repmat({''}, size(dTable, 1), 1);
end

if any(strcmp(dTable.Properties.VariableNames, 'fileUid'))
    dTable.fileUID = dTable.fileUid;
end

names = dTable.Properties.VariableNames;
shapeProp = names{contains(names,'shape_')};
switch shapeProp
    case 'shape_bbox_xywh'
        dTable.shape = struct('type','bbox_xywh', ...
            'data', dTable.(shapeProp));
        invalid = cellfun(@(c)isempty(c), dTable.(shapeProp));
        invalid = invalid | cellfun(@(c)all(isnan(c)), dTable.(shapeProp));
        dTable.(shapeProp) = [];
end

dStruct.source = dTable.source{1};
dStruct.fileUID = dTable.fileUID{1};

uFrames = unique(dTable.frameIndex);

for i = 1:length(uFrames)
    cInds = dTable.frameIndex == uFrames(i);
    frameStruct = table2struct(dTable(cInds,:));
    frameStruct(invalid(cInds)) = [];
    if uFrames(i) > 0
        dStruct.frameDeclarations.(sprintf('f%d',uFrames(i))).declarations = frameStruct;
    else
        error('Some frames indices were < 1, but frames in DECL files are 1-based');
    end
end
end