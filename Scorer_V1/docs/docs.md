# Atlas Scorer Repo Documentation

## Purpose

This document provide an overview of the Atlas_Scorer repo, including relevant file formats (`.decl.json`, `.decl.csv`, `.truth.json`) and basic code usage.  After reading this document, practitioners should be able to create their own declaration and annotation files, and evaluate the performance of system declarations (alarms) against actual objects annotations (truth).

## AiTR Problem Statement / Overview

At its most basic, AiTR algorithm scoring is the process of associating algorithm alerts (declarations) with known entities in ground-truth files (annotations) and generating performance metrics (e.g., ROC curves, confusion matrices) based on these associations.  To provide a concrete example, consider Figure 1, where data from a frame (33) from a file (uid: cegr_1923_0003) has been presented to an AiTR algorithm (orange).  The AiTR algorithm has generated declarations (the blue boxes in the top-center image in Figure 1) around several locations in a frame of data.  Evaluating the performance of the algorithm requires identifying the associated ground truth which contains annotations around the actual objects of interest (green boxes, bottom-center image).

![test](./images/fig_proc_flow.PNG)
*Figure 1: Scoring system overview & nomenclature.  Each data/video file (left) is assigned a fileUID, and each fileUID has corresponding ground truth in the form of “annotations”.  When an algorithm processes a frame, it generates “declarations” (alarms).  “Linking” refers to the process by which declarations are associated with zero or more annotations within the same frame (only declarations and annotations from the same frame and same fileUID are eligible for linking).  “Aggregation” refers to the process by which the resulting declarations, annotations, link matrix, and declaration confidences are reduced to a scorable vector of confidences and labels.  Note that in most cases, this process is repeated for all relevant frames in all the relevant fileUIDs to constitute a final overall algorithm score.*

Given declarations and annotations, the process of scoring can be conceptually separated into two distinct phases: linking and aggregation.  Linking is the process by which each declaration is associated with zero or more annotations.  Typically, this is done using a combination of geometric relationships (e.g., does this declaration bounding box overlap significantly with any declarations?), and (optionally) a class-based criterion (e.g., does this declaration’s class (“Tank”) match the annotation’s class?).  The output of linking is well represented as a binary, sparse matrix of size #declarations x #annotations (see the top right table in Figure 1).  Note that a linking matrix enables us to infer which declarations are connected to annotations (purple boxes, center right) and which declarations are not associated with any annotations (orange boxes, center right).  

Aggregation is the process by which a set of declarations, annotations, and a linking matrix are combined to form a metric of interest (typically a ROC curve) based on various pieces of meta-logic.  At its most basic, a simple detection ROC curve can be created by aggregating all declaration connected to each annotation, retaining the highest confidence declaration, labeling all these as “true-positives”, and counting each declaration not linked to any annotation as a false-positive (See the bottom right of Figure 1).

The Atlas Scorer repo attempts to provide a common workflow for unified algorithm scoring similar to the workflow outlined in Figure 1, by: 1. Providing common, simple, extensible data exchange formats for system declarations and ground truth annotations, 2. Providing easy-to-use linking and aggregating code in both MATLAB and PYTHON, and 3. Providing powerful hooks enabling in-depth data analytics and scoring options for varying linking and aggregation approaches.

## File Formats

We need common consistent and extensible file formats for describing algorithm declarations and ground truth annotations.  We have developed two JSON specifications for these two tasks: `.decl.json` files are intended to hold algorithm declarations from a particular fileUID, and `.truth.json` files are intended to hold ground truth annotations from a particular fileUID.

### *.decl.json

![overview of decl.json](./images/fig_decl_json.PNG)
*Figure 2: Description of the *.decl.json format.*

### *.decl.csv format

![overview of decl.csv](./images/fig_decl_csv.PNG)
*Figure 3: Description of the *.decl.csv format.*

### *.truth.json

![overview of truth.json](./images/fig_truth_json.PNG)
*Figure 4: Description of the *.truth.json format.*

## Scoring Code Basics

A typical use of the Atlas Scorer code base involves identifying DECL and TRUTH files for analysis, loading, and then linking the files.  Generating a valid Scorer object requires

1. Loading the TRUTH and DECL files
2. Linking with the `.link()` method
3. Aggregating with the `.aggregate()` method

In Python (see \docs\examples\example_scoring.py):

``` python
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
roc, _ = scorer.aggregate()
```

In MATLAB (see \docs\examples\example_scoring.m):

``` matlab
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
roc = scorer.aggregate();
```

### Loading Only Some Frames from All DECL and TRUTH files

Sometimes it is convenient to only process a subset of all the frames in a file (for speed), or to only score a subset of frames from a file (for memory reasons, speed, or for specialized analytics).  Scorer objects enable frame down-selection during DECL and TRUTH loading to enable these kinds of analytics.  

In Python (see \docs\examples\example_scoring_frameSelector.py):

``` python
# Use the above python example to load the truth_files and decl_files
scorer = Scorer()
scorer.frame_remove_function = lambda i: i % 60 > 0
scorer.load(truth_files, decl_files)
scorer.link()
roc, _ = scorer.aggregate()
```

In MATLAB (see \docs\examples\example_scoring_frameSelector.m):

``` matlab
% Use the above python example to load the truth_files and decl_files
scorer = atlasScorer();
scorer.frameRemoveFunction = @(i) mod(i,60);
scorer.load(truthFiles, declFiles);
scorer.link();
roc = scorer.aggregate();
```

### Scoring Detection vs. Identification

By default, Atlas Scorer scores declarations and annotations in detection mode, where any declaration on any annotation counts as a “detection”.  We can change this behavior by calling .aggregate with the `alg` option.  If we set the `alg` option to `'identification'`, declarations and annotations will onyl be considered linked if the class in the declaration matches the class in the annotation (and the declaration and annotation are geometrically linked).

For the example CFAR DECLs, these result in poor ROC curves, because CFAR does not output a class for each declaration!

In Python (see \docs\examples\example_scoring_identification.py):

``` python
scorer = Scorer()
scorer.load(truth_files, decl_files)
scorer.link()
# Since CFAR declarations don't have a class, the resulting ROC curve will not
# measure any detections (since none of the declaration classes match the
# annotation classes!)
roc, _ = scorer.aggregate(alg='identification')
```

In MATLAB (see \docs\examples\example_scoring_identification.m):

``` matlab
scorer = atlasScorer();
scorer.load(truthFiles, declFiles);
scorer.link();
% Note: since the CFAR algorithm provides no class labels, this will result
% in NO true positives, but all the algorithm outputs do count as false
% alarms
roc = scorer.aggregate('alg', 'identification');
```

### Scoring a Single Class

Sometimes we also want to break down performance (identification or detection) by the target class.  This is easy to do with the `score_class` option to `.aggregate()`

In PYTHON (see \docs\examples\example_scoring_score_class.py):

``` python
scorer = Scorer()
scorer.frame_remove_function = lambda i: i % 30 > 0
scorer.load(truth_files, decl_files)
scorer.link()

roc_pickup, _ = scorer.aggregate(alg='detection', score_class='PICKUP')
# Since there are no BMP2's in these files the roc_bmp2.pd will be NaN
roc_bmp2, _ = scorer.aggregate(alg='detection', score_class='BMP2')
```

In MATLAB (see \docs\examples\example_scoring_score_class.m):

``` matlab
scorer = atlasScorer();
scorer.frameRemoveFunction = @(i) mod(i,30);
scorer.load(truthFiles, declFiles);
scorer.link();
roc_pickup = scorer.aggregate('alg', 'detection', 'score_class', 'PICKUP');
% Note: There are no BMP-2 objects in these files, so the PD will be NaN for this
% example
roc_bmp2 = scorer.aggregate('alg', 'detection', 'score_class', 'BMP-2');
```

## Scoring Code Advanced

### Removing Annotations & Declarations

TODO

### Ignorable Annotations & Declarations

TODO

### Annotation H1/H0 Labels

TODO

## Future Software & Documentation Improvements

* (DOC) Improve the provided DECL.JSOn and TRUTH.JSON files to include a good example of the identification and class-specific scoring functionality
* (DOC) Finish the advanced scoring section
* (DOC) Add terms to the Glossary
* (DOC) Provide instructions for validating JSON and CSV files
* (CODE) Enable more general matching of class names using a user-defined taxonomy/ontology.  So that, e.g., a declaration with class "Vehicle" can match multiple classes
* (CODE) Simplify the process of overloading the _link_frame method behavior.  This should be more straightforward than it is.
* (CODE) Remove MARSHMALLOW/Schema; these have proven to be slow when enabled
* (CODE) Include additional outputs from aggregation that allow users to obtain the declarations and annotations responsible for each confidence/label in the ROC curve
* (CODE) Change the AtlasMetricROC object to store the confidences and labels internally, removing the need for the second output from .aggregate().  
* (CODE) Provide some utility functions, e.g., to generate all detection and identification ROC curves for all target classes in the annotations.
* (CODE) Provide visualization utilities, e.g., for displaying declarations and annotations on an image

## Glossary

*Annotation* An annotation (also known as truth, or an object) is a representation of a region in an image that is known to contain something of interest to algorithm developers, typically because it contains a target of interest.  Annotations consist of at least a spatial region and object class specification.

*Bounding Box* A representation of the location (in pixels) of a declaration or annotation.  Atlas Scorer only allows for bounding boxes of the form [x, y, w, h] where x represents the x-location of the top-left corner of the bounding box, y represents the y location of the top-left corner of the bounding box, and w and h represent the width and height of the bounding box.  All measurements are in pixels, and the top-left corner of the image is assumed to be [1,1].  

*Class* A string representing the type of object in an annotation or declaration.  Typical classes are “Pickup”, “ZSU-23”, “T-72”, “Person”, etc.

*Confidence* A real-value indicating the strength of the algorithm’s belief in the current declaration.  These confidence values can be any real number, but larger numbers should always indicate increased confidence.  If two algorithms are to be fused into one ROC curve, it is important to ensure that they output confidence values in the same scale (e.g., typically in [0, 1]).

*Declaration* A declaration (also known as an alarm) is a representation of a region in an image an algorithm has identified as interesting, typically because it contains a target of interest.  Declarations consist of at least a spatial region (bounding box), confidence, and class estimate.

*fileUID*  A unique string for each data file or “run”.  Declarations and annotations can only be associated with one another if both the fileUID and the Frame Index match.  

*Frame Index*  The index of the data frame in the data file.  These indices are 1-based, so the first frame is frame #1.  Declarations and annotations can only be associated with one another if both the fileUID and the Frame Index match.  

*label* A binary label corresponding to an annotation that indicates whether declarations on the annotation should be counted as false-positives (label=0) or detections (label=1).  By defauly, all annotations have label=1
