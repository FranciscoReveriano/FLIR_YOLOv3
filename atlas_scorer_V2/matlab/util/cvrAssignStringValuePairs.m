function [obj,varargin] = cvrAssignStringValuePairs(obj,varargin)
% cvrAssignStringValuePairs - Assigns string value pairs to Matlab
%   objects or structures.
%
% s = cvrAssignStringValuePairs(s,'p1',v1,'p2',v2,...) sets:
%       s.p1 = v1;
%       s.p2 = v2; 
%       etc.
%
% 

opts.handleInvalidField = 'error';
ind = find(strcmpi(varargin,'__handleInvalidField'));
if ~isempty(ind)
    opts.handleInvalidField = varargin{ind+1};
    varargin = varargin(setdiff(1:length(varargin),[ind,ind+1]));
end
matched = false(length(varargin),1);
for i = 1:2:length(varargin)
    
    if ~isa(varargin{i},'char')
        fprintf('Input: #%d: \n',i);
        disp(varargin{i})
        error('Invalid arguments to cvrAssignStringValuePairs, input #%d was not a character',i);
    end
    if isfield(obj,varargin{i}) || isprop(obj,varargin{i})
        obj.(varargin{i}) = varargin{i+1};
        matched(i:i+1) = true;
    else
        switch opts.handleInvalidField
            case 'error'
                error('Could not find a match for field: %s',varargin{i});
            case 'warn'
                warning('Could not find a match for field: %s',varargin{i});
            case 'ignore'
            otherwise
                error('Invalid setting for handleInvalidField: %s',opts.handleInvalidField)
        end
    end
end
varargin = varargin(~matched);
