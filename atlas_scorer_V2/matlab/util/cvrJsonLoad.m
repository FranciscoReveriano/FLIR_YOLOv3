function jsonStruct = cvrJsonLoad(file)
% jsonStruct = cvrJsonLoad(file)
%   Read the contents of the file into a structure using fileread and
%   jsondecode.


% fileread is much faster than fscanf!
s = fileread(file);
jsonStruct = jsondecode(s);
