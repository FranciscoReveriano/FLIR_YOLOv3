classdef atlasScorer < matlab.mixin.Copyable
    % atlasScorer
    %   An object for scoring ATLAS data.
    %
    %   Typical usage:
    %
    %   % truthFiles and declFiles are cell arrays of .truth.json and
    %   % .decl.json files
    %   s = atlasScorer();
    %   s.load(truthFiles, declFiles); 
    %   roc = s.score();
    %   plot(roc.far, roc.pd);
    %
    %   % Ignore distant targets
    %   s = atlasScorer();
    %   s.annotationIgnorableFunction = @(a) a.range > 5500;
    %   s.load(truthFiles, declFiles); 
    %   roc = s.score();
    %   plot(roc.far, roc.pd);
    %   
    %   % Less memory:
    %   s = atlasScorer();
    %   s.annotationIgnorableFunction = @(a) a.range > 5500;
    %   roc = s.rocFromFiles(truthFiles, declFiles); 
    % 
    %     The scoring functionality is modularized into three steps:
    %     link
    %     linkFrame
    %     getConfidenceLabels
    % 
    %     If it is desirable to change how annotations are linked to declarations,
    %     Scorer should be subclassed, and linkFrame should be overridden.
    %     atlasScorer should be thought of as the 'default' scorer, while scorers
    %     with other linking methods can be used with minimal code changes.
    % 
    %     Settable properties:
    %         verbose - if True, will print status messages.
    % 
    %     In addition, several function handles are used to determine how to
    %     handle each annotation and declaration during scoring. The full
    %     annotation and declaration metadata are passed to these functions
    %     and can therefore be used to make specific changes to the scoring
    %     based on metadata: e.g. ignoring annotations >5km.
    % 
    %     These functions will be applied during load time, as that is when
    %     all the metadata will be available.
    %
    %       frameRemoveFunction ~ A function handle that accepts a one-based frame
    %          index (e.g., a number in [1, 1800]).  If the function returns
    %          true, declarations and annotations corresponding to those
    %          frames are removed when the annotations and declarations are
    %          loaded.
    %
    %           Examples to score every 30th frame, or only the first 30
    %           frames:
    %
    %           scorer.frameRemoveFunction = @(f) mod(f, 30);
    %           scorer.frameRemoveFunction = @(f) f > 30;
    % 
    %     annotationRemoveFunction - A function handle that accepts an M x
    %           N annotation table and returns a M x 1 boolean.  If the
    %           returned value is true, the corresponding annotation
    %           (truth) is not considered during aggregating.
    %           
    %           Examples to remove people.  NOTE this will result in
    %           false-positives for any declaration that was on the person!
    %            See annotationIgnorableFunction below.
    %
    %           scorer.annotationRemoveFunction = @(a) strcmpi(a.class, 'MAN');
    %           
    % 
    %     declarationRemoveFunction - A function handle that accepts an M x
    %           N declaration table and returns a M x 1 boolean.  If the
    %           returned value is true, the corresponding declaration
    %           (truth) is not considered during aggregating.
    %           
    %           Example to retain only high-confidence alarms (>1):
    %
    %           scorer.declarationRemoveFunction = @(d) d.confidence <= 1;
    %       
    % 
    %     annotationBinaryLabelFunction - A function handle that accepts an
    %         M x N annotation table, and returns a 1 or 0 indicating whether
    %        the annotation should be considered a HIT or a MISS.  This
    %        method is used during aggregation, and can be changed in an
    %        atlasScorer object after linking.  By default, all annotations
    %        have a binary label of "1".
    %
    %       Example:
    %           scorer.annotationBinaryLabelFunction = @(a) ~strcmpi(a.class,'bush');
    %
    %     annotationIgnorableFunction - A function handle that accepts an
    %        M x N annotation table, and returns a 1 if the annotation should
    %        be treated as 'don't care'.  Declarations that are linked to
    %        annotIgnorable annotations are not treated as false positives nor true
    %       detections, and annotations that are annotIgnorable do not count
    %       as targets for the purposes of calculating PD.  This
    %        method is used during aggregation, and can be changed in an
    %        atlasScorer object after linking.
    % 
    %       Example to ignore detections on distant targets:
    %           scorer.annotationIgnorableFunction = @(a) a.range > 5500;
    %
    %     scoring properties:
    %      annotationTable ~ nAnnotations x M MATLAB table of annotations.
    %         Set during load().
    %
    %      declarationTable ~ nDeclarations x N MATLAB table of
    %         declarations.  Set during load().
    %
    %      detLinkMatrix ~ nDeclarations x nAnnotations sparse matrix of
    %         detection "links" between the annotations and declarations
    %         based on the proximity of their "shapes" (bounding boxes).
    %         Set during link().
    %
    %       idLinkMatrix ~ nDeclarations x nAnnotations sparse matrix of
    %         identification "links" between the annotations and
    %         declarations based on the proximity of their "shapes"
    %         (bounding boxes) and class string matches. Set during link().
    %         
    properties
        annotationTable
        declarationTable
        detLinkMatrix
        idLinkMatrix
        nFrames = 0
    end
    
    properties
        frameRemoveFunction = @(frameIndex) false(size(frameIndex));
        annotationRemoveFunction = @(declTable) false(size(declTable, 1), 1);
        declarationRemoveFunction = @(declTable) false(size(declTable, 1), 1);
        
        annotationBinaryLabelFunction = @(annotTable) true(size(annotTable, 1), 1);
        annotationIgnorableFunction = @(annotTable) false(size(annotTable, 1), 1);
        
        verbose = false;
    end
    
    properties (Dependent)
        uniqueDeclUIDs
        uniqueAnnotUIDs
    end
    
    methods
        function u = get.uniqueDeclUIDs(self)
            u = unique(self.declarationTable.fileUID);
        end
        
        function u = get.uniqueAnnotUIDs(self)
            u = unique(self.annotationTable.fileUID);
        end
        
        function self = atlasScorer(varargin)
            self = cvrAssignStringValuePairs(self, varargin{:});
        end
        
        function [roc, confs, labels] = aggregate(self, varargin)
            % [roc, confs, labels] = aggregate(self)
            %   Generate an annotation detection ROC-curve, confidences and
            %   label vectors.
            %
            % [roc, confs, labels] = aggregate(self, ...)
            %   Enables setting various aggregation configuration
            %   parameter / value pairs:
            %
            %       'alg' ~ (str, default: 'detection') ~ A character
            %       vector indicating whether to perform 'detection' or
            %       'identification' based scoring.
            %
            %       'score_class' ~ (str, default: '') ~ If non-empty, the
            %       class to generate ROC curves for.
            %
            % Note: During scoring, if score_class is specified, the
            % following changes are made to the outputs of
            % annotationIgnorable, declarationRemove, and annotationLabel
            % function outputs:
            %
            %   Detection:
            %       ignorable = ignorable | (~annotIsClass & labels == 1)
            %       labels = isClass
            %   Identification:
            %       declRemove = declRemove | ~declIsClass
            %       labels = isClass
            
            opts = struct('alg', 'detection', ...
                'score_class', '');
            opts = cvrAssignStringValuePairs(opts, varargin{:});
            
            annotRemove = self.annotationRemoveFunction(self.annotationTable);
            declRemove = self.declarationRemoveFunction(self.declarationTable);
            
            % annotationBinaryLabelFunction maps from annotations to either
            % a 0 or a 1 (default behavior is all annotations get label 1).
            % This enables us to treat, for example, declarations on
            % annotated bushes as "false positives".  Use
            % annotationIgnorableFunction to specify that alerts on some
            % annotations can be ignored.
            annotLabels = self.annotationBinaryLabelFunction(self.annotationTable);
            assert(numel(annotLabels) == size(self.annotationTable, 1));
            
            % IGNORABLE targets should not be counted as true detections,
            % even when a declaration is on the object.  Note that anything
            % annotIgnorable will also not count as a false alarm.
            annotIgnorable = self.annotationIgnorableFunction(self.annotationTable);
            assert(numel(annotIgnorable) == size(self.annotationTable, 1));
            
            switch lower(opts.alg)
                case 'detection'
                    
                    linkMatrix = self.detLinkMatrix;
                    if ~isempty(opts.score_class)
                        if ~isempty(self.annotationTable)
                            isClass = strcmpi(self.annotationTable.class, ...
                                opts.score_class);
                            % For detection, add all annotations that dont 
                            % match the scoring class AND are real objects
                            % to the ignorable list:
                            annotIgnorable = annotIgnorable | ...
                                (~isClass & annotLabels == 1);
                            
                            % Note: enforce un-ignorable & label = 1 for
                            % the current class of interest
                            % annotIgnorable = annotIgnorable & ~isClass;
                            % The only thing we care about is the current
                            % class!
                            annotLabels = isClass;
                        end
                    end
                    
                case 'identification'
                    linkMatrix = self.idLinkMatrix;
                    if ~isempty(opts.score_class)
                        if ~isempty(self.declarationTable)
                            dIsClass = strcmpi(self.declarationTable.class, ...
                                opts.score_class);
                            aIsClass = strcmpi(self.annotationTable.class, ...
                                opts.score_class);
                            
                            declRemove = declRemove | ~dIsClass;
                            annotLabels = aIsClass;
                        end
                    end
                otherwise
                    error('%s is not a valid scorer.aggregate alg', opts.alg);
            end
            
            confidenceVec = [];
            if size(linkMatrix, 1) > 0
                confidenceVec = cat(1, self.declarationTable.confidence);
            end
            % Setting the confidence to NAN effectively ignores these
            % declarations
            confidenceVec(declRemove) = nan;
            % Annotations where linked declarations can be interpreted as
            % detections are where: the label is 1, the object is not
            % ignorable, AND the object is not set for removal.
            tpAnnotations = annotLabels & ~annotIgnorable & ~annotRemove;
            % Annotations where linked declarations can be interpreted
            % as false positives are where: the label is 0, the object is not
            % ignorable, OR the object is set for removal.
            faAnnotations = ~annotLabels & ~annotIgnorable | annotRemove;
            
            % False alarms are linked to Nothing, 
            % or are linked only to annotations that are false-positives
            faIndicator = ~any(linkMatrix, 2);
            faIndicator = faIndicator | ...
                ~any(linkMatrix(:,~faAnnotations), 2);
            % Remove the non-false-alarm confidences; we can safely remove
            % NaN's here using ~declRemove
            faConfidences = confidenceVec(faIndicator & ~declRemove);
            
            % To get the confidence on actual annotations of interest, we
            % use MAX aggregation of remaining confidences over true
            % detections. This is easiest to do by annotating over the
            % whole linkMatrix, and removing non-true-positives down below
            [i, j] = find(linkMatrix);
            tpConfidences = accumarray(j, confidenceVec(i), ...
                [size(linkMatrix, 2), 1], @max, nan);
            tpConfidences = tpConfidences(tpAnnotations);
            
            labels = cat(1, zeros(size(faConfidences)), ones(size(tpConfidences)));
            confs = cat(1, faConfidences, tpConfidences);
            roc = atlasScoreRoc(confs, labels);
            roc.farDenominator = self.nFrames;
            
        end
        
        function roc = score(self)
            self.link();
            roc = self.aggregate();
        end
        
        function reset(self)
            self.nFrames = 0;
            self.annotationTable = [];
            self.declarationTable = [];
            self.detLinkMatrix = [];
            self.idLinkMatrix = [];
        end
        
        function link(self)
            % link(self) Generates the internal self.detLinkMatrix and
            %    self.idLinkMatrix by iteratively calling self.linkFrame(a,d)
            %    on unique annotations and declarations from uid/frame#
            %    combinations.
            %
            %   
            
            % The matrix itself should be nDeclarations x nAnnotations, but
            % we cannot reliably initialize the number-of-ones any better
            % than spalloc and guessing since we don't know how many detections
            % there might be.  3 per annotation seems like a good guess:
            %   ~1 Annotation per frame, PD~%100 + FAR~2FA/Frame
            %
            
            % ldlm -> localDetLinkMatrix
            % lilm -> localIdLinkMatrix
            [ldlm, lilm] = deal(spalloc(size(self.declarationTable, 1), ...
                size(self.annotationTable, 1), ...
                size(self.annotationTable, 1) * 3));
            
            if size(ldlm,1) == 0
                self.detLinkMatrix = ldlm;
                self.idLinkMatrix = lilm;
                return
            end
            
            uniqueUids = unique(self.annotationTable.fileUID);
            for eUid = cvrEnumerate(uniqueUids)
                
                uidDeclIndicator = strcmp(self.declarationTable.fileUID, eUid.value);
                uidAnnotIndicator =  strcmp(self.annotationTable.fileUID, eUid.value);
                uniqueFrames = unique(self.declarationTable.frameIndex(uidDeclIndicator));
                
                for eFrame = cvrEnumerate(uniqueFrames)
                    frameDeclLogical = uidDeclIndicator ...
                        & self.declarationTable.frameIndex == eFrame.value;
                    frameAnnotLogical = uidAnnotIndicator ...
                        & self.annotationTable.frameIndex == eFrame.value;
                    
                    cDeclTable = self.declarationTable(frameDeclLogical,:);
                    cAnnotTable = self.annotationTable(frameAnnotLogical,:);
                    [detLinks, idLinks] = self.linkFrame(cDeclTable, cAnnotTable);
                    
                    ldlm(frameDeclLogical, frameAnnotLogical) = detLinks;
                    lilm(frameDeclLogical, frameAnnotLogical) = idLinks;
                end
            end
            self.detLinkMatrix = ldlm;
            self.idLinkMatrix = lilm;
        end
        
        % The INUSL warning here is OK - people need to overload this 
        % method to make different linkFrame methods; leave the explicit
        % self in there for clarity.
        function [detLinkMatrix, idLinkMatrix] = ...
                linkFrame(self, declarations, annotations) %#ok<INUSL>
            % [detMatrix, idMatrix] = self.linkFrame(d, a) for a
            % declaration table, d, and annotation table, a, where all
            % declarations and annotations are from the same frame and same
            % uid, linkFrame generates the size(d,1) x size(a,1) sparse 
            % matrices detMatrix and idMatrix, which take value 1 in M(i,j)
            % if declaration i is linked to annotation j.
            %
            %   TODO: simplify overloading this method to provide
            %   alternative detection and identification linking methods.
            PAD = 5;
            [detLinkMatrix, idLinkMatrix] = ...
                deal(sparse(size(declarations, 1), ...
                    size(annotations, 1)));
            if isempty(detLinkMatrix)
                return;
            end
            dShapes = cat(1, declarations.shape);
            aShapes = cat(1, annotations.shape);
            
            dBoxes = atlasShape.structToBbox(dShapes);
            aBoxes = atlasShape.structToBbox(aShapes);
            
            dCenters = dBoxes(:,1:2) + dBoxes(:,3:4)/2;
            % Detect Link Matrix and Id Link Matrix
            [dlm, ilm] = deal(false(size(dBoxes,1), size(aBoxes,1)));
            for i = 1:size(dBoxes,1)
                dlm(i,:) = (dCenters(i,1) >= aBoxes(:,1) - PAD & ...
                    dCenters(i,1) <= aBoxes(:,1) + aBoxes(:,3) + PAD) & ...
                    (dCenters(i,2) >= aBoxes(:,2) - PAD & ...
                    dCenters(i,2) <= aBoxes(:,2) + aBoxes(:,4) + PAD);
                
                ilm(i,:) = strcmpi(declarations.class(i), annotations.class);
            end
            % ID links are only valid where the declaration was on the
            % annotation
            ilm = ilm & dlm;
            
            detLinkMatrix = sparse(dlm);
            idLinkMatrix = sparse(ilm);
        end
        
        function rocMetric = rocFromFiles(self, truthFileCell, declFileCell)
            % calculate an ROC curve from a list of files. This method will
            % not store annotation and declaration tables, and thus is
            % faster and less memory intensive.
            nFramesTotal = 0;
            confs = [];
            labels = [];
            for i = 1:length(truthFileCell)
                self.load(truthFileCell{i}, declFileCell{i});
                self.link();
                [~, confs_, labels_] = self.aggregate();
                
                confs = cat(1, confs, confs_);
                labels = cat(1, labels, labels_);
                nFramesTotal = nFramesTotal + self.nFrames;
            end
            rocMetric = atlasScoreRoc(confs, labels);
            rocMetric.farDenominator = nFramesTotal;
            
            if nargout == 0
                rocMetric.plotFar();
            end
        end
        
        function self = load(self, truthFileCell, declFileCell)
            % Load a list of truth and declaration files into memory
            % and convert them into tables.  Note that
            % frameRemoveFunction() is applied during loading to save
            % memory.
            
            if nargout
                self = self.copy();
            end
            self.reset()
            
            if ~iscell(truthFileCell)
                truthFileCell = {truthFileCell};
            end
            if ~iscell(declFileCell)
                declFileCell = {declFileCell};
            end
            
            for i = 1:length(declFileCell)
                if self.verbose
                    fprintf('Reading %d/%d\n\tDECL: %s\n\tTRUTH: %s\n',...
                        i, length(declFileCell), ...
                        declFileCell{i},...
                        truthFileCell{i});
                    tic();
                end
                cdTable = atlasDeclarationRead(declFileCell{i});
                caTable = atlasAnnotationRead(truthFileCell{i});
                cFrames = caTable.Properties.UserData.nFrames;
                
                remove = logical(self.frameRemoveFunction((1:cFrames)'));
                assert(numel(remove) == cFrames);
                
                self.nFrames = self.nFrames + cFrames - sum(remove);
                
                keep = ~remove;
                
                if ~isempty(cdTable)
                    keepDeclFrames = keep(cdTable.frameIndex);
                    cdTable = cdTable(keepDeclFrames,:);
                end
                
                if ~isempty(caTable)
                    keepAnnotFrames = keep(caTable.frameIndex);
                    caTable = caTable(keepAnnotFrames,:);
                end
                
                if i == 1
                    dTable = cdTable;
                    aTable = caTable;
                else
                    dTable = cat(1, dTable, cdTable);
                    aTable = cat(1, aTable, caTable);
                end
                if self.verbose
                    fprintf('\t Took %.1f secs\n', toc);
                end
            end
            
            self.annotationTable = aTable;
            self.declarationTable = dTable;
        end
        
    end
end
