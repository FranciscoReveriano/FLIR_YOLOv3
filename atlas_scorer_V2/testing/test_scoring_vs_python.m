%%
clearvars;
close all;

testFolderSource = '\\coVarNas4\CI-Data\AtlasScorer\2019.08.12\sourceFiles';
testFolderOut = '\\coVarNas4\CI-Data\AtlasScorer\2019.08.12\outFiles';
declFiles = {fullfile(testFolderSource,'cegr01923_0001.cfar.decl.json'), ...
     fullfile(testFolderSource,'cegr01923_0002.cfar.decl.json'), ...
     fullfile(testFolderSource,'cegr01923_0005.cfar.decl.json')};
 
truthFiles = {fullfile(testFolderSource,'cegr01923_0001.truth.json'), ...
     fullfile(testFolderSource,'cegr01923_0002.truth.json'), ...
     fullfile(testFolderSource,'cegr01923_0005.truth.json')};

%% Default scoring!
scorer = atlasScorer();
scorer = scorer.load(truthFiles, declFiles);
roc = scorer.score();
rocIter = scorer.rocFromFiles(truthFiles, declFiles);

t = table(roc.nfa, roc.far, roc.pd, roc.tau, ...
    'VariableNames', {'nfa', 'far', 'pd', 'tau'});
writetable(t, fullfile(testFolderOut,'test.default.matlab.csv'));

t = table(rocIter.nfa, rocIter.far, rocIter.pd, rocIter.tau, ...
    'VariableNames', {'nfa', 'far', 'pd', 'tau'});
writetable(t, fullfile(testFolderOut,'test.default.iter.matlab.csv'));

%% Scoring with annotation label & ignorable functions:
scorer = atlasScorer();
scorer.annotationBinaryLabelFunction = @(a) a.range < 1000;
scorer.annotationIgnorableFunction = @(a) a.range >= 1010;
scorer = scorer.load(truthFiles, declFiles);
roc = scorer.score();
rocIter = scorer.rocFromFiles(truthFiles, declFiles);

t = table(roc.nfa, roc.far, roc.pd, roc.tau, ...
    'VariableNames', {'nfa', 'far', 'pd', 'tau'});
writetable(t, fullfile(testFolderOut,'test.annotationFunctions.matlab.csv'));

t = table(rocIter.nfa, rocIter.far, rocIter.pd, rocIter.tau, ...
    'VariableNames', {'nfa', 'far', 'pd', 'tau'});
writetable(t, fullfile(testFolderOut,'test.annotationFunctions.iter.matlab.csv'));

%% Scoring with frame & decl selection functions:
scorer = atlasScorer();
scorer.frameRemoveFunction = @(i) mod(i, 30) > 0;
scorer.annotationRemoveFunction = @(a) a.range > 1000;
scorer.declarationRemoveFunction = @(d) d.confidence > 5;
scorer = scorer.load(truthFiles, declFiles);
roc = scorer.score();
rocIter = scorer.rocFromFiles(truthFiles, declFiles);

t = table(roc.nfa, roc.far, roc.pd, roc.tau, ...
    'VariableNames', {'nfa', 'far', 'pd', 'tau'});
writetable(t, fullfile(testFolderOut,'test.removeFunctions.matlab.csv'));

t = table(rocIter.nfa, rocIter.far, rocIter.pd, rocIter.tau, ...
    'VariableNames', {'nfa', 'far', 'pd', 'tau'});
writetable(t, fullfile(testFolderOut,'test.removeFunctions.iter.matlab.csv'));

%%

c = cvrCsvComparer('eps', 1e-6);
c.compare(fullfile(testFolderOut,'test.default.matlab.csv'),...
    fullfile(testFolderOut,'test.default.python.csv'));
assert(all(c.results.maxDifference) < 1e-6)
c.compare(fullfile(testFolderOut,'test.default.iter.matlab.csv'),...
    fullfile(testFolderOut,'test.default.iter.python.csv'));
assert(all(c.results.maxDifference) < 1e-6)
c.compare(fullfile(testFolderOut,'test.annotationFunctions.matlab.csv'),...
    fullfile(testFolderOut,'test.annotationFunctions.python.csv'))
assert(all(c.results.maxDifference) < 1e-6)
c.compare(fullfile(testFolderOut,'test.annotationFunctions.iter.matlab.csv'),...
    fullfile(testFolderOut,'test.annotationFunctions.iter.python.csv'))
assert(all(c.results.maxDifference) < 1e-6)
c.compare(fullfile(testFolderOut,'test.removeFunctions.matlab.csv'),...
    fullfile(testFolderOut,'test.removeFunctions.python.csv'))
assert(all(c.results.maxDifference) < 1e-6)
c.compare(fullfile(testFolderOut,'test.removeFunctions.iter.matlab.csv'),...
    fullfile(testFolderOut,'test.removeFunctions.iter.python.csv'))
assert(all(c.results.maxDifference) < 1e-6)
