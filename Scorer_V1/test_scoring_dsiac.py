import sys
import os
import matplotlib.pyplot as plt

from Scorer_V1.python.atlas_scorer.score import Scorer


cur_dir, _ = os.path.split(sys.argv[0])
print(cur_dir)

truth_files = [os.path.join(cur_dir, '/home/franciscoAML/Documents/DSIAC/Five_Classes/Version2.0/yolov3/Truth_JSON/cegr01923_0001.truth.json')]
decl_files = [os.path.join(cur_dir, '/home/franciscoAML/Documents/DSIAC/Five_Classes/Version2.0/yolov3/WrittenDecl/cegr01923_0001.decl.json')]

scorer = Scorer()
scorer = scorer.load(truth_files, decl_files)
roc = scorer.roc_from_files(truth_files, decl_files)

# ---------------------------------
# Examples for generating ROC plots
# ---------------------------------
# Plot Pd-FAR on linear scale
#roc.plot_far(title='FAR Plot', label='Expt 1')

# Plot Pd-FAR on log scale for x-axis
#ax = roc.plot_far(title='FAR Plot', label='Expt 1')
#ax.set_xscale('log')
#ax.autoscale(True)  # Reset x-axis lims since default of ~0 doesn't work well with log scale

# Plot Pd-Pf
roc.plot_roc(label='Expt 1')
plt.show()