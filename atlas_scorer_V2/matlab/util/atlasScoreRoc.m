function roc = atlasScoreRoc(x, y)
% atlasScoreRoc is a replacement for prtScoreRoc that we can re-distribute
if isempty(x) && isempty(y)
    roc = atlasMetricRoc('pf',[],'pd',[],'nfa',[],...
        'tau',[],'auc',NaN,'nTargets', 0,'nNonTargets',0);
    return
end

uY = unique(y);

if length(uY) ~= 2
    % Changed 2015.04.07 --> ROC curves no longer error for single-class
    % inputs as long as the input class is either Y == 1 or Y == 0. 
    if (length(uY) == 1 && uY == 0) || (length(uY) == 1 && uY == 1)
        warning('atlasScoreRoc:roc:oneClass','One-class of data (Class: %d) was provided to atlasScoreRoc; this will result in NaN PD or PF values',uY);
        uY = [0 1];
    else
        error('atlasScoreRoc:roc:wrongNumberClasses','ROC requires input labels to have 2 unique classes or the single class must have class number 0 or 1, but unique(y(:)) = %s\n',mat2str(unique(y(:))));
    end
end

if length(x) ~= length(y)
	error('length(x) (%d) must equal length(y) (%d)',length(x),length(y));
end
newY = y;
newY(y==uY(1)) = 0;
newY(y==uY(2)) = 1;
y = newY;

[sortedDS, sortingInds] = sort(x,'descend');
nanSpots = isnan(sortedDS);
sortedY = y(sortingInds);

pFa = double(~sortedY); % number of false alarms as a function of threshold
pD = double(sortedY); % number of detections as a function of threshold

% Detect and handle ties
if length(sortedDS) > 1
	isTiedWithNext = cat(1,sortedDS(1:(end-1)) == sortedDS(2:end),false);
else
	isTiedWithNext = false;
end

% If there are any ties we need to figure out the tied regions and set each
% of the ranks to the average of the tied ranks.
if any(isTiedWithNext)
	diffIsTiedWithNext = diff(isTiedWithNext);
	
	if isTiedWithNext(1) % First one is tied
		diffIsTiedWithNext = cat(1,1,diffIsTiedWithNext);
	else
		diffIsTiedWithNext = cat(1,0,diffIsTiedWithNext);
	end
	
	% Start and stop regions of the ties
	tieRegions = cat(2,find(diffIsTiedWithNext==1),find(diffIsTiedWithNext==-1));
	
	% For each tied region
	% We set the first value of PD (or PF) in the tied region equal to the
	% number of hits (or non-hits) in the range and we set the rest to zero
	% This makes sure that when we cumsum (integrate) we get all of the
	% tied values at the same time.
	for iRegion = 1:size(tieRegions,1)
		pD(tieRegions(iRegion,1)) = sum(pD(tieRegions(iRegion,1):tieRegions(iRegion,2)));
		pD((tieRegions(iRegion,1)+1):(tieRegions(iRegion,2))) = 0;
		pFa(tieRegions(iRegion,1)) = sum(pFa(tieRegions(iRegion,1):tieRegions(iRegion,2)));
		pFa((tieRegions(iRegion,1)+1):(tieRegions(iRegion,2))) = 0;
	end
end
nH1 = sum(sortedY);
nH0 = length(sortedY)-nH1;

pD(nanSpots & ~~sortedY) = 0; % NaNs are not counted as detections
pFa(nanSpots & ~sortedY) = 0; % or false alarms

pD = cumsum(pD)/nH1;
nFa = cumsum(pFa);
pFa = nFa/nH0;

pD = cat(1,0,pD);
pFa = cat(1,0,pFa);
nFa = cat(1,0,nFa);

thresholds = cat(1,inf,sortedDS(:));
auc = trapz(pFa,pD);
roc = atlasMetricRoc('pf',pFa,'pd',pD,'nfa',nFa,...
    'tau',thresholds,'auc',auc,'nTargets', nH1,'nNonTargets',nH0);
