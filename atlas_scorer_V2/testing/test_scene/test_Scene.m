clearvars;
clc;
%% 1
scorer = atlasScorer();
scorer.load('C:\Users\Peter Torrione\Documents\code\atlas_scorer\testing\testScene.truth.json', ...
    'C:\Users\Peter Torrione\Documents\code\atlas_scorer\testing\testScene.decl.json');
scorer.link();
[roc, confs, labels] = scorer.aggregate('alg', 'detection');
assert(isequal(confs, [1 8 8 8]'));
assert(isequal(labels, [0 1 1 1]'));

%% 2
scorer = atlasScorer();
scorer.load('C:\Users\Peter Torrione\Documents\code\atlas_scorer\testing\testScene.truth.json', ...
    'C:\Users\Peter Torrione\Documents\code\atlas_scorer\testing\testScene.decl.json');
scorer.link();
[roc, confs, labels] = scorer.aggregate('alg', 'identification');
assert(isequal(confs, [1 2 8 7]'));
assert(isequal(labels, [0 1 1 1]'));

%% 3
scorer = atlasScorer();
scorer.load('C:\Users\Peter Torrione\Documents\code\atlas_scorer\testing\testScene.truth.json', ...
    'C:\Users\Peter Torrione\Documents\code\atlas_scorer\testing\testScene.decl.json');
scorer.link();
scorer.annotationBinaryLabelFunction = @(a) strcmpi(a.class, 'car');
[roc, confs, labels] = scorer.aggregate('alg', 'detection');
assert(isequal(confs, [1 2 3 4 8]'));
assert(isequal(labels, [0 0 0 0 1]'));

%% 4
scorer = atlasScorer();
scorer.load('C:\Users\Peter Torrione\Documents\code\atlas_scorer\testing\testScene.truth.json', ...
    'C:\Users\Peter Torrione\Documents\code\atlas_scorer\testing\testScene.decl.json');
scorer.link();
scorer.annotationBinaryLabelFunction = @(a) strcmpi(a.class, 'car');
[roc, confs, labels] = scorer.aggregate('alg', 'identification');
assert(isequal(confs, [1 2 3 4 8 7]'));
assert(isequal(labels, [0 0 0 0 0 1]'));

%% 5
scorer = atlasScorer();
scorer.load('C:\Users\Peter Torrione\Documents\code\atlas_scorer\testing\testScene.truth.json', ...
    'C:\Users\Peter Torrione\Documents\code\atlas_scorer\testing\testScene.decl.json');
scorer.link();
scorer.annotationBinaryLabelFunction = @(a) strcmpi(a.class, 'car');
scorer.annotationIgnorableFunction = @(a) strcmpi(a.class, 'tree');
[roc, confs, labels] = scorer.aggregate('alg', 'detection');
assert(isequal(confs, [1 2 8]'));
assert(isequal(labels, [0 0 1]'));

%% 6
scorer = atlasScorer();
scorer.load('C:\Users\Peter Torrione\Documents\code\atlas_scorer\testing\testScene.truth.json', ...
    'C:\Users\Peter Torrione\Documents\code\atlas_scorer\testing\testScene.decl.json');
scorer.link();
scorer.annotationBinaryLabelFunction = @(a) strcmpi(a.class, 'car');
scorer.annotationIgnorableFunction = @(a) strcmpi(a.class, 'tree');
[roc, confs, labels] = scorer.aggregate('alg', 'identification');
assert(isequal(confs, [1 2 7]'));
assert(isequal(labels, [0 0 1]'));


%% 7
scorer = atlasScorer();
scorer.load('C:\Users\Peter Torrione\Documents\code\atlas_scorer\testing\testScene.truth.json', ...
    'C:\Users\Peter Torrione\Documents\code\atlas_scorer\testing\testScene.decl.json');
scorer.link();
scorer.annotationBinaryLabelFunction = @(a) strcmpi(a.class, 'car');
scorer.annotationIgnorableFunction = @(a) strcmpi(a.class, 'tree');
[roc, confs, labels] = scorer.aggregate('alg', 'detection', 'score_class', 'tree');
assert(isequal(confs, [1 2]'));
assert(isequal(labels, [0 0]'));

%% 8
scorer = atlasScorer();
scorer.load('C:\Users\Peter Torrione\Documents\code\atlas_scorer\testing\testScene.truth.json', ...
    'C:\Users\Peter Torrione\Documents\code\atlas_scorer\testing\testScene.decl.json');
scorer.link();
scorer.annotationBinaryLabelFunction = @(a) strcmpi(a.class, 'car');
scorer.annotationIgnorableFunction = @(a) strcmpi(a.class, 'tree');
[roc, confs, labels] = scorer.aggregate('alg', 'detection', 'score_class', 'sky');
assert(isequal(confs, [1 8]'));
assert(isequal(labels, [0 1]'));

%% 9 
scorer = atlasScorer();
scorer.load('C:\Users\Peter Torrione\Documents\code\atlas_scorer\testing\testScene.truth.json', ...
    'C:\Users\Peter Torrione\Documents\code\atlas_scorer\testing\testScene.decl.json');
scorer.link();
scorer.annotationBinaryLabelFunction = @(a) strcmpi(a.class, 'car');
scorer.annotationIgnorableFunction = @(a) strcmpi(a.class, 'tree');
[roc, confs, labels] = scorer.aggregate('alg', 'identification', 'score_class', 'tree');
assert(isequal(confs, zeros(0,1)));
assert(isequal(labels, zeros(0,1)));

%% 10
[roc, confs, labels] = scorer.aggregate('alg', 'identification', 'score_class', 'sky');
assert(isequal(confs, [1 2]'));
assert(isequal(labels, [0 1]'));