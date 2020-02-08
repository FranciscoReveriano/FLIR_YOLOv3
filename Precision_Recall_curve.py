import matplotlib.pyplot as plt
import numpy as np

# Open the file
precision = np.loadtxt("/home/franciscoAML/Documents/DSIAC/Five_Classes/Version2.0/yolov3/Scores/Test_3/results.txt", usecols=[8], ndmin=2)
recall = np.loadtxt("/home/franciscoAML/Documents/DSIAC/Five_Classes/Version2.0/yolov3/Scores/Test_3/results.txt", usecols=[9], ndmin=2)
assert(len(precision) == len(recall))

# Print Possible Results
print("Length:", len(precision))

# Plot Figure
fig = plt.figure()
ax = plt.subplot(111)
ax.plot(recall, precision, color="red", label="Precision-Recall")
plt.xlabel("Precision")
plt.ylabel("Recall")
plt.title("Precision - Recall Curve")
plt.show()