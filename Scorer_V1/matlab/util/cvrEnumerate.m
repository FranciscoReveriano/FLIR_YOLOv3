function structArray = cvrEnumerate(vals,dim)
% structArray = cvrEnumerate(vals)
%   Use to enumerate a set of values, similar to the pythonic enumerate:
%
%   % In PYTHON
%   my_list = ['apple', 'banana', 'grapes', 'pear']
%   for c, value in enumerate(my_list, 1):
%         print(c, value)
%
%   % In MATLAB
%   my_list = {'apple', 'banana', 'grapes', 'pear'}
%   for iter = cvrEnumerate(my_list)
%         disp(iter)
%   end
%
% The output structArray is a 1 x nIters structure with fields 
%   .index ~ the index of the element
%   .value ~ the value
%
% By default nIters is numel(vals), but see below for special cases.
%
% The primary use case is inside a for-loop, like so:
%   myVec = randn(1,5);
%   for iter = 1:length(myVec)
%       cVal = myVec(iter);
%       % do something
%   end
%
%   vs. 
%   for iter = cvrEnumerate(myVec)
%       cVal = iter.value;
%       % do something
%   end
%
%
% structArray = cvrEnumerate(vals,dim = 0)
%   Iterate over the specified dimension.  By default (dim = 0), iterates
%   over every element of the matrix or vector vals (note, this is
%   different from default MATLAB behavior, which for some reason iterates
%   over columns by default)
%
%   matrix = randn(3,10);
%   for mlIter = matrix % by default, MATLAB iterates over COLS
%       disp(mlIter)  % every mlIter is 3x1
%   end
%
%   % vs. 
%
%   for iter = cvrEnumerate(matrix) 
%       disp(iter)  % every iter.value is 1x1, 30 iterations
%   end
%
%   for iter = cvrEnumerate(matrix,1) 
%       disp(iter)  % every iter.value is 1x10, 3 iterations
%   end
%
%   for iter = cvrEnumerate(matrix,2) 
%       disp(iter)  % every iter.value is 3x1, 10 iterations
%   end

if nargin == 1
    dim = 0;
end

if dim == 0
    if ~isa(vals,'cell')
        vals = num2cell(vals);
    end
    inds = num2cell(1:numel(vals));
    structArray = struct('index',inds,'value',vals(:)','maxIndex',numel(vals));
else
    dimCell = num2cell(size(vals));
    dimCell{dim} = ones(size(vals,dim),1);
    %     if ~isa(vals,'cell')
    %         vals = num2cell(vals);
    %     end
    vals = mat2cell(vals,dimCell{:});
    
    inds = num2cell(1:size(vals,dim));
    structArray = struct('index',inds,'value',vals(:)',...
            'maxIndex',length(inds));
end
