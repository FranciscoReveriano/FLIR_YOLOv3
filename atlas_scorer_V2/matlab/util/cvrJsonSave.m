function cvrJsonSave(file,jsonStruct,varargin)

p = inputParser;
p.addParameter('append',false);
p.addParameter('pretty',false);
p.parse(varargin{:});

if p.Results.append && exist(file,'file')
    jsonStruct0 = cvrJsonLoad(file);
    jsonStruct = cat(1,jsonStruct0,jsonStruct);
end

fid = fopen(file,'w');
if fid == -1
    error('Unable to open file: %s',file);
end
cleaner = onCleanup(@()fclose(fid));

jsonString = jsonencode(jsonStruct);
if p.Results.pretty
    jsonString = py.json.dumps(py.json.loads(jsonString),...
        pyargs('indent',sprintf('  ')));
    jsonString = char(jsonString);
end
fprintf(fid,'%s',jsonString);