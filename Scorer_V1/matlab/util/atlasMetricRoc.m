classdef atlasMetricRoc
    % atlasMetricRoc is a replacement for prtMetricRoc that we can
    % distribute
    % 
    properties
        nTargets
        nNonTargets
        pd
        pf
        nfa
        farDenominator = nan;
        tau
        auc
        
        thresholds = [];
    end
    properties (Dependent)
        sensitivity
        hitRate
        recall
        truePositiveRate
        
        specificity
        trueNegativeRate
        
        precision
        positivePredictiveValue
        
        negativePredictiveValue
        
        missRate
        falseNegativeRate
        
        fallOut
        falsePositiveRate
        
        falseDiscoveryRate
        falseOmissionRate
        
        accuracy
        f1 % f1 score
        mmc % mathews correlation coefficient
        bm % informedness or Bookmaker informedness
        mk % markedness
        
        
        % Counds rather than pd/pf
        tp
        fp
        tn
        fn
        
        far % nfa / farDenominator
    end
    
    methods
        function self = atlasMetricRoc(varargin)
            self = cvrAssignStringValuePairs(self,varargin{:});
        end
        
        function val = get.sensitivity(self)
            val = self.pd;
        end
        function val = get.hitRate(self)
            val = self.pd;
        end
        function val = get.truePositiveRate(self)
            val = self.pd;
        end
        function val = get.recall(self)
            val = self.pd;
        end
        
        function val = get.specificity(self)
            val = self.tn ./ self.nNonTargets;
        end
        function val = get.trueNegativeRate(self)
            val = self.specificity;
        end
        
        function val = get.precision(self)
            val = self.tp ./ (self.tp + self.fp);
        end
        function val = get.positivePredictiveValue(self)
            val = self.precision;
        end
        
        function val = get.falseNegativeRate(self)
            val = self.fn ./ (self.fn + self.tp);
        end
        function val = get.missRate(self)
            val = self.falseNegativeRate;
        end
        function val = get.falsePositiveRate(self)
            val = self.fp ./ (self.fp + self.tn);
        end
        function val = get.fallOut(self)
            val = self.falsePositiveRate;
        end
        function val = get.falseDiscoveryRate(self)
            val = self.fp ./ (self.fp + self.tp);
        end
        
        function val = get.falseOmissionRate(self)
            val = self.fn ./ (self.fn + self.tn);
        end
            
        function val = get.accuracy(self)
            val = (self.tp + self.tn) ./ (self.tp + self.tn + self.fp + self.fn);
        end
        function val = get.f1(self)
            val = (2*self.tp)./(2*self.tp + self.fp + self.fn);
        end
        function val = get.mmc(self)
            val = (self.tp.*self.tn - self.fp.*self.fn) ./ sqrt( (self.tp + self.fp).*(self.tp + self.fn).*(self.tn + self.fp).*(self.tn + self.fn) ); 
        end
        function val = get.bm(self)
            val = self.truePositiveRate + self.trueNegativeRate - 1;
        end
        function val = get.mk(self)
            val = self.positivePredictiveValue + self.negativePredictiveValue - 1;
        end
        
        function val = get.far(self)
            val = self.nfa./self.farDenominator;
        end
        
        function val = get.tp(self)
            val = self.pd * self.nTargets;
        end
        function val = get.tn(self)
            val = (1-self.pf) * self.nNonTargets;
        end
        function val = get.fp(self)
            val = self.pf * self.nNonTargets;
        end
        function val = get.fn(self)
            val = (1-self.pd) * self.nTargets;
        end
        

        
        function [meanRoc,stdRoc,pfVals] = getRocStatistics(self,pfVals)
            % [meanRoc,stdRoc] = getRocStatistics(self,nPoints)
            % [meanRoc,stdRoc] = getRocStatistics(self,farVals)
            % get mean & std of a bunch of ROCs
            if nargin < 2
                pfVals = 250;
            end
            
            if numel(pfVals) == 1
                allPf = cat(1,self(:).pf);
                pfVals = linspace(0,max(allPf),pfVals);
            end
            
            pdVals = self.pdAtPfValues(pfVals);
            pdVals = cat(2,pdVals{:});
            
            meanRoc = nanmean(pdVals,2);
            stdRoc = nanstd(pdVals,[],2);
            
        end
        
        
        function [meanRoc,stdRoc,farVals] = getRocFarStatistics(self,farVals)
            % [meanRoc,stdRoc] = getRocStatistics(self,nPoints)
            % [meanRoc,stdRoc] = getRocStatistics(self,farVals)
            % get mean & std of a bunch of ROCs
            if nargin < 2
                farVals = 250;
            end
            
            if numel(farVals) == 1
                allFar = cat(1,self(:).far);
                farVals = linspace(0,max(allFar),farVals);
            end
            
            pdVals = self.pdAtFarValues(farVals);
            pdVals = cat(2,pdVals{:});
            
            meanRoc = nanmean(pdVals,2);
            stdRoc = nanstd(pdVals,[],2);
            
        end
        
        function pdOut = pdAtFarValues(self,farPoints)
            if numel(self)>1
                pdOut = cell(size(self));
                for iSelf = 1:numel(self)
                    pdOut{iSelf} = self(iSelf).pdAtFarValues(farPoints);
                end
                return
            end
            
            tmpFar = self.far;
            tmpFar(end+1) = Inf;
            tmpPd = self.pd;
            tmpPd(end+1) = nan;
            
            indOut = arrayfun(@(s)find(tmpFar>s,1),farPoints);
            %ind = find(self.far > farPoints,1,'first');
            pdOut = tmpPd(indOut);
        end
        
        function pdOut = pdAtPfValues(self,pfPoints)
            if numel(self)>1
                pdOut = cell(size(self));
                for iSelf = 1:numel(self)
                    pdOut{iSelf} = self(iSelf).pdAtPfValues(pfPoints);
                end
                return
            end
            
            % return nan values if past ROC curve
            tmpPf = self.pf;
            tmpPf(end+1) = Inf;
            tmpPd = self.pd;
            tmpPd(end+1) = nan;
            
            indOut = arrayfun(@(s)find(tmpPf>s,1),pfPoints);
            %ind = find(self.far > farPoints,1,'first');
            pdOut = tmpPd(indOut);
        end
        
        function pfOut = pfAtPdValues(self,pdPoints)
            if numel(self)>1
                pfOut = cell(size(self));
                for iSelf = 1:numel(self)
                    pfOut{iSelf} = self(iSelf).pfAtPdValues(pdPoints);
                end
                return
            end
            
            % return nan values if past ROC curve
            tmpPf = self.pf;
            tmpPf(end+1) = Inf;
            tmpPd = self.pd;
            tmpPd(end+1) = Inf;
            
            indOut = arrayfun(@(s)find(tmpPd>s,1),pdPoints);
            %ind = find(self.far > farPoints,1,'first');
            pfOut = tmpPf(indOut);
        end
        
        function [farOut,indOut] = farAtPdValues(self,pdPoints)
            if numel(self)>1
                farOut = cell(size(self));
                indOut = cell(size(self));
                for iSelf = 1:numel(self)
                    [farOut{iSelf},indOut{iSelf}] = self(iSelf).farAtPdValues(pdPoints);
                end
                return
            end
            
            % return nan values if past ROC curve
            tmpFar = self.far;
            tmpFar(end+1) = Inf;
            tmpPd = self.pd;
            tmpPd(end+1) = Inf;
            
            indOut = arrayfun(@(s)find(tmpPd>=s,1,'first'),pdPoints);
            %ind = find(self.far > farPoints,1,'first');
            farOut = tmpFar(indOut);
        end
        
        function self = atThreshold(self,threshold)
            
            index = find(self.tau > threshold,1,'last');
            self.pd = self.pd(index);
            self.nfa = self.nfa(index);
            self.pf = self.pf(index);
            self.tau = self.tau(index);
            self.auc = nan;
        end
        
        function varargout = plot(self,varargin)
            
            holdState = ishold;
            
            h = gobjects(length(self),1);
            for i = 1:numel(self)
                if isempty(self(i).pf)
                    continue
                end
                h(i) = plot(self(i).pf,self(i).pd,varargin{:});
                hold on;
            end
            if ~holdState
                hold off
            end
            
            if nargout
                varargout = {h};
            else
                varargout = {};
            end
        end
        function varargout = plotNfa(self,varargin)
            
            holdState = ishold;
            
            h = gobjects(length(self),1);
            for i = 1:numel(self)
                h(i) = plot(self(i).nfa,self(i).pd,varargin{:});
                hold on;
            end
            if ~holdState
                hold off
            end
            
            if nargout
                varargout = {h};
            else
                varargout = {};
            end
        end
        
        function varargout = semilogFar(self, varargin)
            
            semilogxOffset = 1e-6;
            holdState = ishold;
            h = gobjects(length(self),1);
            for i = 1:length(self)
                h(i) = semilogx(self(i).far + semilogxOffset, ...
                    self(i).pd,varargin{:});
                hold on;
            end
            if ~holdState
                hold off
            end
            ylim([0 1]);
            if nargout
                varargout = {h};
            else
                varargout = {};
            end
        end
        
        
        function varargout = plotFar(self,varargin)
            
            holdState = ishold;
            
            h = gobjects(length(self),1);
            for i = 1:length(self)
                h(i) = plot(self(i).far,self(i).pd,varargin{:});
                hold on;
            end
            if ~holdState
                hold off
            end
            ylim([0 1]);
            if nargout
                varargout = {h};
            else
                varargout = {};
            end
            
        end
        function varargout = plotRocFar(self,varargin)
            varargout = cell(nargout,1);
            [varargout{:}] = plotFar(self,varargin{:});
        end
        
        function ds = assignValue(self, ds, fieldName)
            % Find the closest tau and use the corresponding field name as the updated X confidence
            
            assert(ds.nFeatures == length(self),'prt:prtMetricRoc:assignValue','Invalid input. Number of features in dataset and number of rocs must match');
            if nargin < 3 || isempty(fieldName)
                fieldName = 'pf';
            end
            assert(ismember(fieldName, {'pd','pf','nfa','far'}),'prt:prtMetricRoc:assignValue','Invalid input. fieldName must be one of {''pd'',''pf'',''nfa''}');
            
            useFar = false;
            if strcmpi(fieldName,'far')
                fieldName = 'nfa';
                useFar = true;
            end
            
            flipTau = false;
            newX = nan([ds.nObservations length(self)]);
            for iRoc = 1:length(self)
                
                cX = ds.X(:,iRoc);
                nTau = numel(self(iRoc).tau);
                if flipTau
                    flippedTau = flipud(self(iRoc).tau);
                end
                
                binInd = zeros(size(cX,1),1);
                for iObs = 1:size(cX,1)
                    cVal = cX(iObs);
                    if isnan(cVal)
                        cBin = nan;
                    elseif ~isfinite(cVal)
                        % +/-Inf
                        if flipTau
                            if cVal > 0 % +Inf
                                cBin = nTau;
                            else %-Inf
                                cBin = 1;
                            end
                        else
                            if cVal > 0 % Inf
                                cBin = 1;
                            else
                                cBin = nTau; % -Inf
                            end
                        end
                    else
                        if flipTau
                            cBin = find(cVal >= flippedTau,1,'last');
                        else
                            cBin = find(self(iRoc).tau >= cVal, 1, 'last');
                        end
                        
                        if isempty(cBin)
                            cBin = 1; % First bin?..
                        end
                    end
                    binInd(iObs) = cBin;
                end
                
                %[~, binInd] = histc(cX,flippedTau);
                
                nonNans = ~isnan(binInd);
                if flipTau
                    flippedField = flipud(self(iRoc).(fieldName));
                    newX(nonNans,iRoc) = flippedField(binInd(nonNans)); 
                else
                    newX(nonNans,iRoc) = self(iRoc).(fieldName)(binInd(nonNans)); 
                end
            end
            
            if useFar
                newX = newX ./ self.farDenominator;
            end
            
            ds.X = newX;
        end
        function pauc = aucFar(self, maxFar)
            
            if nargin < 2 || isempty(maxFar)
                maxFar = -inf; % This will be ignored
            end
            
            pauc = zeros(size(self));
            for iRoc = 1:numel(self)
                
                nTarget = self(iRoc).nTargets;
                uPd = linspace(0,1,nTarget+1);
                uPdFar = self(iRoc).farAtPdValues(uPd);
                
                cX = uPdFar(:);
                cY = uPd(:);
                                
                keep = cX <= maxFar;
                cX = cX(keep);
                cY = cY(keep);
                
                % Append a last point @ maxFar to ensure we get the final
                % rectangle up to the requested FAR - note: Can optionally
                % include the trapezoidal extension... but that's not
                % actually the PD you would get based on the data we've
                % seen.  It's a conundrum and the extension is complicated,
                % and adds no real benefit.
                cX = cat(1,cX,maxFar);
                cY = cat(1,cY, cY(end));
                
                pauc(iRoc) = trapz(cX,cY);
            end
        end
    end
end
