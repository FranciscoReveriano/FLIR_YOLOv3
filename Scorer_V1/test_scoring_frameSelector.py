import sys
import os
import matplotlib.pyplot as plt

from Scorer_V1.python.atlas_scorer.score import Scorer

cur_dir, _ = os.path.split(sys.argv[0])

decl_source_dir = '/home/franciscoAML/Documents/DSIAC/Five_Classes/Version2.0/yolov3/WrittenDecl/'
truth_source_dir = '/home/franciscoAML/Documents/DSIAC/Five_Classes/Version2.0/yolov3/Truth_JSON/'
out_dir = '/home/franciscoAML/Documents/DSIAC/Five_Classes/Version2.0/yolov3/Scores'

#decl_files = [os.path.join(decl_source_dir, 'cegr01923_0001.decl.json'),os.path.join(decl_source_dir, 'cegr01923_0002.decl.json'),os.path.join(decl_source_dir, 'cegr01923_0006.decl.json')]
#truth_files = [os.path.join(truth_source_dir, 'cegr01923_0001.truth.json'),os.path.join(truth_source_dir, 'cegr01923_0002.truth.json'),os.path.join(truth_source_dir, 'cegr01923_0006.truth.j###son')]

decl_files = []
for fileName in os.listdir(decl_source_dir):
    decl_files.append(os.path.join(decl_source_dir,fileName))

truth_files = []
for name in decl_files:
    newName = name[78:92] + ".truth.json"
    truth_files.append(os.path.join(truth_source_dir, newName))

print(decl_files)
print(truth_files)
# Some Error Checking
assert(len(decl_files) == len(truth_files))

scorer = Scorer()
scorer.load(truth_files, decl_files)
scorer.link()
roc, _ = scorer.aggregate(alg='detection')
# Plot Pd-Pf
roc.plot_far(title='FAR Plot', label='Expt 1')
plt.show()