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

scorer = Scorer()
scorer.frame_remove_function = lambda i: i % 30 > 0
scorer.load(truth_files, decl_files)
scorer.link()
# Since CFAR declarations don't have a class, the resulting ROC curve will not
# measure any detections (since none of the declaration classes match the
# annotation classes!)
roc, _ = scorer.aggregate(alg='identification')