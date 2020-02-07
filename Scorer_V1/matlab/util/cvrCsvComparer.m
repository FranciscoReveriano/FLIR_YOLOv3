classdef cvrCsvComparer < matlab.mixin.SetGet & matlab.mixin.Copyable
    % cvrCsvComparer 
    %   An object for comparing two CSV files
    %
    %   % Example:
    %       % Test1.csv has columns col1 .. col10
    %       % Test2.csv has the same columns EXCEPT for col3, and also has
    %       % newCol1, and new Col2.  Also, the value of the 5th entry in
    %       % col5 is different
    %   rootDir = fullfile(cvrRoot,'misc','csv','testCsvs');
    %   csv1 = fullfile(rootDir,'test1.csv');
    %   csv2 = fullfile(rootDir,'test2.csv');
    %   
    %   c = cvrCsvComparer('handleDifferentLengths','truncate');
    %   c.run(csv1,csv2);
    %   
    %   c.plot('col5');
    %
    
    properties
        results             % Set by "run"
        verbose = true;     % Whether to displayResults() at the end of a run
        eps = eps;          % The max allowed difference before flagging a change
        csv1 = '';          % The name of the first CSV
        csv2 = '';          % The name of the second CSV
        table1 = [];        % The result of readtable(csv1)
        table2 = [];        % The result of readtable(csv1)
        handleDifferentLengths = 'error'; % {'error' or 'truncate'} if "truncate", shorten the longer of the two tables
    end
    
    methods
        
        function self = cvrCsvComparer(varargin)
            self = cvrAssignStringValuePairs(self,varargin{:});
        end
        
        function displayResults(self)
            % comparer.displayResults
            %   Show text with a display of the information in self.results
            %   
            
            if self.results.lengthEquality
                matchStr = 'matched';
            else
                matchStr = 'DID NOT MATCH';
            end
            removed = sprintf('{ %s };',sprintf('''%s'', ',self.results.removedColumns{:}));
            added = sprintf('{ %s };',sprintf('''%s'', ',self.results.newColumns{:}));
            fprintf('Results: \n     CSV #Rows %s (%.0d,%.0d)\n     %d columns differed significantly\n     %d columns added %s\n     %d columns removed %s\n',matchStr,...
                self.results.originalTable1Length,self.results.originalTable2Length,sum(self.results.maxDifference > self.eps),...
                length(self.results.newColumns),added,length(self.results.removedColumns),removed);
            
            for sharedIndex = 1:length(self.results.sharedColumns)
                if abs(self.results.maxDifference(sharedIndex)) > self.eps
                    pre = '***';
                else
                    pre = '   ';
                end
                fprintf('%sColumn %s differed by: %.8f @ sample %d\n',pre,self.results.sharedColumns{sharedIndex},self.results.maxDifference(sharedIndex),self.results.maxDifferenceIndex(sharedIndex));
                if self.results.nanDifference(sharedIndex)
                    fprintf('%s\t %s NAN values differed @ sample %d\n',pre,self.results.sharedColumns{sharedIndex},self.results.nanDifferenceIndex(sharedIndex));
                end
            end
        end
        
        function compare(self,csv1,csv2)
            % comparer.compare(csv1,csv2)
            %   An alias for "run(self,csv1,csv2)"
            self.run(csv1,csv2);
        end
        
        function run(self,csv1,csv2)
            % comparer.run(csv1,csv2)
            %   Compare the CSV files
            %
            %   1) read the csv1 and csv2 into table1 and table2 (the csvs
            %   must be compatible with readtable)
            %
            %   2) Generate a list of sharedColumns, removedColumns (in
            %   csv1 and NOT in csv2), and addedColumns (in csv2 and NOT in
            %   csv1)
            %   
            %   3) For numeric columns, calculate the max difference and
            %   the index of the max difference
            %   
            %   4) For non-numeric columns check equality.
            %
            %   5) Store the results in comparer.results (a struct)
            
            self.csv1 = csv1;
            self.csv2 = csv2;
            self.table1 = readtable(csv1);
            self.table2 = readtable(csv2);
            
            columns1 = self.table1.Properties.VariableNames;
            columns2 = self.table2.Properties.VariableNames;
            
            sharedColumns = intersect(columns1,columns2);
            removedColumns = setdiff(columns1,columns2);
            newColumns = setdiff(columns2,columns1);
            
            equality = false(length(sharedColumns),1);
            maxDifference = nan(length(sharedColumns),1);
            maxDifferenceIndex = nan(length(sharedColumns),1);
            nanDifference = false(length(sharedColumns),1);
            nanDifferenceIndex = nan(length(sharedColumns),1);
            originalTable1Length = size(self.table1,1);
            originalTable2Length = size(self.table2,1);
            lengthEquality = originalTable1Length == originalTable2Length;
            if ~lengthEquality
                switch self.handleDifferentLengths
                    case 'error'
                        error('cvrCsvComparer:incompatibleSize','The variables in the csvs are of different lengths (%d vs %d)',originalTable1Length,originalTable2Length);
                    case 'truncate'
                        warning('cvrCsvComparer:incompatibleSize','The variables in the csvs are of different lengths (%d vs %d)',originalTable1Length,originalTable2Length);
                        minLen = min([originalTable1Length,originalTable2Length]);
                        self.table1 = self.table1(1:minLen,:);
                        self.table2 = self.table2(1:minLen,:);
                    otherwise
                        error('unknown handleDifferentLengths option (%s)',self.handleDifferentLengths);
                end
            end
            
            for sharedIndex = 1:length(sharedColumns)
                v1 = self.table1.(sharedColumns{sharedIndex});
                v2 = self.table2.(sharedColumns{sharedIndex});
                equality(sharedIndex) = isequaln(v1,v2);
                if isnumeric(v1) && isnumeric(v2)
                    [maxDifference(sharedIndex),maxDifferenceIndex(sharedIndex)] = max(abs(v1-v2));
                    nanDifference(sharedIndex) = any(isnan(v1) ~= isnan(v2));
                    if nanDifference(sharedIndex)
                        nanDifferenceIndex(sharedIndex) = find(isnan(v1) ~= isnan(v2),1,'first');
                    end
                elseif isnumeric(v1) || isnumeric(v2)
                    warning('Column %s was numeric in one CSV, and not in the other',sharedColumns{sharedIndex});
                end
            end
            self.results = struct('originalTable1Length',originalTable1Length,'originalTable2Length',originalTable2Length,...
                'lengthEquality',lengthEquality,...
                'totalEquality',all(equality) && isempty(removedColumns) && isempty(newColumns),...
                'sharedColumns',{sharedColumns},'newColumns',{newColumns},'removedColumns',{removedColumns},...
                'equality',equality,'maxDifference',maxDifference,'maxDifferenceIndex',maxDifferenceIndex,...
                'nanDifference',nanDifference,'nanDifferenceIndex',nanDifferenceIndex);
            if self.verbose
                self.displayResults();
            end
        end
        
        function [hLines,hError] = plot(self,traceName)
            % comparer.plot(traceName)
            %   Make a plot of the trace data from table1 and table2
            %   
            y1 = self.table1.(traceName);
            y2 = self.table2.(traceName);
            if length(y1) ~= length(y2)
                warning('Truncating traces for plotting');
                tLen = min(length(y1),length(y2));
                y1 = y1(1:tLen);
                y2 = y2(1:tLen);
            end
            subplot(2,1,1); 
            hLines = plot(cat(2,y1,y2));
            title(traceName,'interpreter','none');
            [~,f1] = fileparts(char(self.csv1));
            [~,f2] = fileparts(char(self.csv2));
            legend(hLines,{f1,f2},'interpreter','none');
            subplot(2,1,2); 
            hError = plot(cat(2,y1-y2));
            title('Difference');
            tightenY('axesHandles',gca)
            linewidth(2)
            linkaxeseasy x;
        end
    end
end
