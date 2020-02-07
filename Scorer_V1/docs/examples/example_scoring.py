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
scorer.load(truth_files, decl_files)
# .link(), .aggregate() is equivalent to:
# roc = scorer.score()
scorer.link()
# Note: performance will be poor because the CFAR DECL files provided only
# contain declarations for every 30th frame, but we scored against all frames!
# See example_scoring_frameSelector.m
roc, _ = scorer.aggregate()