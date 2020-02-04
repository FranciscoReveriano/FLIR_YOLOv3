%% Example code for MATLAB atlasScorer processing .hits.decl.csv and 
%.truth.json 
% 
%
%   Some of these folders and files may not be available on your system,
%   but you should have similar .truth.json and .decl.csv (or .decl.json)
%   files available for scoring.
%
clearvars;
close all;
clc

mtiStiDir = '\\coVarNas4\Data4\users\Pete\atlas\mti_sti_hits_dets';
truthDir = '\\coVarNas4\Data4\users\Pete\atlas\truth\dsiac\';

fileUids = {'cegr01923_0001','cegr01923_0002','cegr01923_0005',...
    'cegr01923_0006','cegr01923_0009','cegr01923_0011','cegr01923_0012',...
    'cegr01923_0013','cegr01923_0014','cegr01925_0001','cegr01925_0002',...
    'cegr01925_0005','cegr01925_0006','cegr01925_0009','cegr01925_0011',...
    'cegr01925_0012','cegr01925_0013','cegr01925_0014','cegr01927_0001',...
    'cegr01927_0002','cegr01927_0005','cegr01927_0006','cegr01927_0009',...
    'cegr01927_0011','cegr01927_0012','cegr01927_0013','cegr01927_0014',...
    'cegr01929_0001','cegr01929_0002','cegr01929_0005','cegr01929_0006',...
    'cegr01929_0009','cegr01929_0011','cegr01929_0012','cegr01929_0013',...
    'cegr01929_0014','cegr01931_0001','cegr01931_0002','cegr01931_0005',...
    'cegr01931_0006','cegr01931_0009','cegr01931_0011','cegr01931_0012',...
    'cegr01931_0014','cegr01933_0001','cegr01933_0002','cegr01933_0005',...
    'cegr01933_0006','cegr01933_0009','cegr01933_0011','cegr01933_0012',...
    'cegr01933_0014','cegr01935_0001','cegr01935_0002','cegr01935_0005',...
    'cegr01935_0006','cegr01935_0009','cegr01935_0011','cegr01935_0012',...
    'cegr01935_0014','cegr01937_0001','cegr01937_0002','cegr01937_0005',...
    'cegr01937_0006','cegr01937_0009','cegr01937_0011','cegr01937_0012',...
    'cegr01937_0014','cegr01939_0001','cegr01939_0002','cegr01939_0005',...
    'cegr01939_0006','cegr01939_0009','cegr01939_0011','cegr01939_0012',...
    'cegr01939_0014'};


truthList = cellfun(@(f)fullfile(truthDir,[f,'.truth.json']), fileUids, ...
    'UniformOutput',false);
       
hitsList = cellfun(@(f)fullfile(mtiStiDir,[f,'.hits.decl.csv']), fileUids, ...
    'UniformOutput',false);

%% Example: Score frames 30, 60, 90, etc.
scorer = atlasScorer();
scorer.frameRemoveFunction = @(f) mod(f, 30);
scorerHits_30 = scorer.copy();
scorerHits_30.load(truthList, hitsList);
rocHits_30 = scorerHits_30.score();

h = semilogFar(rocHits_30);
linewidth(3);
grid on;
grid minor;
legend(h,{'Hits'});
title('ROC Curves for Every 30 Frames');

%% Example: Only Score the first 30 frames

scorer = atlasScorer();
scorer.frameRemoveFunction = @(f) f > 30;
scorerHits_first30 = scorer.copy();
scorerHits_first30.load(truthList, hitsList);

rocHits_first30 = scorerHits_first30.score();

figure;
h = semilogFar(rocHits_first30);
linewidth(3);
grid on;
grid minor;
legend(h,{'Hits'});
title('ROC Curves for First 30 Frames');


%% Example: treat very far away targets as ignorable - 
% this is useful, e.g., for YUMA, but has limited impact on DSIAC.  I
% didn't have time to run this code, but I think it will work as expected

scorer = atlasScorer();
scorer.frameRemoveFunction = @(f) mod(f, 30);
scorer.annotationIgnorableFunction = @(a) a.range > 6000;
scorerHits_30ignoreFar = scorer.copy();
scorerHits_30ignoreFar.load(truthList, hitsList);
rocHits_30ignoreFar = scorerHits_30ignoreFar.score();

h = semilogFar(rocHits_30ignoreFar);
linewidth(3);
grid on;
grid minor;
legend(h,{'Hits'});
title('ROC Curves for Every 30 Frames');

%% Example: go file-by-file

scorer = atlasScorer();
scorer.frameRemoveFunction = @(f) mod(f, 30);
scorerHits_30= scorer.copy();
scorerHits_30.load(truthList, hitsList);

% With Manual modifications of the annotation and declaration tables to do
% each file independently
for fileIndex = 1:length(fileUids)
    scorerHitsLocal = scorerHits_30.copy();
    retain = strcmpi(scorerHitsLocal.declarationTable.fileUID, fileUids{fileIndex});
    scorerHitsLocal.declarationTable = ...
        scorerHitsLocal.declarationTable(retain, :);
    
    retain = strcmpi(scorerHitsLocal.annotationTable.fileUID, fileUids{fileIndex});
    scorerHitsLocal.annotationTable = ...
        scorerHitsLocal.annotationTable(retain, :);
    
    roc(fileIndex) = scorerHitsLocal.score();
end
roc.semilogFar();


%% At this point, you can dig into the annotations and declarations.  For example:

% >> scorerHitsLocal.declarationTable(30,:)
% ans =
%   1×8 table
%         fileUID         frameIndex    source    class    confidence    aspect    range       shape    
%     ________________    __________    ______    _____    __________    ______    _____    ____________
% 
%     'cegr01939_0014'       900        'hits'     ''          63         NaN       NaN     [1x1 struct]

% Note that any declaration with a NAN confidence is a "false" declaration
% that was made when we processed a frame, but had no declarations