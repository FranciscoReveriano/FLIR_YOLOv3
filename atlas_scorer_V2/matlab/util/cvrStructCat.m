function [structOut, rmFields] = cvrStructCat(dim, varargin)
% [structOut, rmFields] = cvrStructCat(dim, s1, s2, ...)
%   Concatenate the structures s1, s2, ... along the dimension dim,
%   retaining only the fields that ALL the structures have in common.
%
%   rmFields is a n x 1 cell, where each cell contains a list of the fields
%   removed from the corresponding structure.

rmFields = cell(numel(varargin), 1);
try
    % This is fast when cat will work!
    structOut = cat(dim, varargin{:});
catch ME
    switch ME.identifier
        case 'MATLAB:catenate:structFieldBad'
            fieldNames = cellfun(@(c)fieldnames(c), varargin, ...
                'UniformOutput', false);
            int = fieldNames{1};
            for i = 2:length(fieldNames)
                int = intersect(int, fieldNames{i});
            end
            for i = 1:length(fieldNames)
                rmFields{i} = setdiff(fieldNames{i}, int);
                varargin{i} = ...
                    rmfield(varargin{i}, rmFields{i});
            end
            structOut = cat(dim, varargin{:});
        otherwise
            rethrow(ME)
    end
end