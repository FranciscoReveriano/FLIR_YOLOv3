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
scorer.frameRemoveFunction = @(i) mod(i,30);
scorer.load(truthFiles, declFiles);
scorer.link();
roc_pickup = scorer.aggregate('alg', 'detection', 'score_class', 'PICKUP');
% Note: There are no BMP-2 objects, so the PD will be NaN for this
% example
roc_bmp2 = scorer.aggregate('alg', 'detection', 'score_class', 'BMP-2');