import sys
import os
import matplotlib.pyplot as plt

from atlas_scorer.score import Scorer

cur_dir, _ = os.path.split(sys.argv[0])

source_dir = '\\\\coVarNas4\\CI-Data\\AtlasScorer\\2019.08.12\\sourceFiles\\'
out_dir = '\\\\coVarNas4\\CI-Data\\AtlasScorer\\2019.08.12\\outFiles\\'

decl_files = [os.path.join(source_dir, 'cegr01923_0001.cfar.decl.json'),
              os.path.join(source_dir, 'cegr01923_0002.cfar.decl.json'),
              os.path.join(source_dir, 'cegr01923_0005.cfar.decl.json')]

truth_files = [os.path.join(source_dir, 'cegr01923_0001.truth.json'),
              os.path.join(source_dir, 'cegr01923_0002.truth.json'),
              os.path.join(source_dir, 'cegr01923_0005.truth.json')]

# Defaults:
scorer = Scorer()
scorer = scorer.load(truth_files, decl_files)
roc = scorer.score()
roc_iter = scorer.roc_from_files(truth_files, decl_files)

roc.write_csv(os.path.join(out_dir, 'test.default.python.csv'))
roc_iter.write_csv(os.path.join(out_dir, 'test.default.iter.python.csv'))

# Use functions to specify annotation labels and ignorable:
#    scorer.annotationBinaryLabelFunction = @(a) a.range < 1000;
#    scorer.annotationIgnorableFunction = @(a) a.range >= 1010;

scorer = Scorer(annotation_binary_label_function=lambda a: a['range']  < 1000,
                annotation_ignorable_function=lambda a: a['range'] >= 1010)
scorer = scorer.load(truth_files, decl_files)
roc = scorer.score()
roc_iter = scorer.roc_from_files(truth_files, decl_files)

roc.write_csv(os.path.join(out_dir, 'test.annotationFunctions.python.csv'))
roc_iter.write_csv(os.path.join(out_dir, 'test.annotationFunctions.iter.python.csv'))

# Use functions to specify removal (done during load time):
#     scorer.frameRemoveFunction = @(i) mod(i, 30) > 0;
#     scorer.annotationRemoveFunction = @(a) a.range > 1000;
#     scorer.declarationRemoveFunction = @(d) d.confidence > 5;

scorer = Scorer(frame_remove_function=lambda i: i % 30 > 0,
                annotation_remove_function=lambda a: a['range'] > 1000,
                declaration_remove_function=lambda d: d['confidence'] > 5)
scorer = scorer.load(truth_files, decl_files)
roc = scorer.score()
roc_iter = scorer.roc_from_files(truth_files, decl_files)

roc.write_csv(os.path.join(out_dir, 'test.removeFunctions.python.csv'))
roc_iter.write_csv(os.path.join(out_dir, 'test.removeFunctions.iter.python.csv'))
