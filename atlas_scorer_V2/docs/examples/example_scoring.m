%%
clearvars;

testFolderSource = '\\coVarNas4\CI-Data\AtlasScorer\2019.08.12\sourceFiles';
testFolderOut = '\\coVarNas4\CI-Data\AtlasScorer\2019.08.12\outFiles';
declFiles = {fullfile(testFolderSource,'cegr01923_0001.cfar.decl.json'), ...
     fullfile(testFolderSource,'cegr01923_0002.cfar.decl.json'), ...
     fullfile(testFolderSource,'cegr01923_0005.cfar.decl.json')};
 
truthFiles = {fullfile(testFolderSource,'cegr01923_0001.truth.json'), ...
     fullfile(testFolderSource,'cegr01923_0002.truth.json'), ...
     fullfile(testFolderSource,'cegr01923_0005.truth.json')};

scorer = atlasScorer();
scorer.load(truthFiles, declFiles);
% link() and then aggregate() is equivalent to:
% roc = scorer.score();
scorer.link();
% Note: performance will be poor because the CFAR DECL files provided only
% contain declarations for every 30th frame, but we scored against all
% frames!  See example_scoring_frameSelector.m
roc = scorer.aggregate();
