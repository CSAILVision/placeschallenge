# Instruction for Semantic Boundary Detection

The semantic boundary detection task is to simultaneously detect whether a pixel belongs to one or possibly multiple predefined semantic boundary classes, such as sky, road, person, and bed. The class definition in this task is identical to the scene parsing subtask, with a total of 150 semantic categories.

Note that we not only consider the boundaries between different semantic categories, but also consider the boundaries between instances with the same semantic class. For example, a pixel between building and sky is labeled as both sky boundary and building boundary, while a pixel between two immediately neighboring persons is considered a person boundary.

The challenge data is divided into 20K images for training, 2K images for validation, and another batch of held-out images for testing.

## Data 

- Download the images [here](http://placeschallenge.csail.mit.edu/data/ChallengeData2017/images.tar). Note that images are the same for all subtasks in Places Challenge 2017. After untarring the image files, the directories should follow the below examples:

training images:

    images/training/ADE_train_00000001.jpg
    images/training/ADE_train_00000002.jpg
        ...
    images/training/ADE_train_00020210.jpg

validation images:

    images/training/ADE_train_00000001.jpg
    images/training/ADE_train_00000002.jpg
        ...
    images/training/ADE_train_00002000.jpg

## Label

- Download the corresponding annotations [here](http://placeschallenge.csail.mit.edu/data/ChallengeData2017/boundaries.tar). The annotation directories should follow the below examples:

training annotations:

    annotations_boundary/training/ADE_train_00000001.mat
    annotations_boundary/training/ADE_train_00000002.mat
        ...
    annotations_boundary/training/ADE_train_00020210.mat

validation annotations:

    annotations_boundary/validation/ADE_val_00000001.mat
    annotations_boundary/validation/ADE_val_00000002.mat
        ...
    annotations_boundary/validation/ADE_val_00002000.mat

Each boundary annotation mat file contains a struct "gt" with two fields named "seg" and "bdry". The "gt.seg" field is a HxWx3 uint8 matrix, with gt.seg(:,:,1) containing the category-level segmentation mask, and gt.seg(:,:,2:3) containing the instance-level mask. Certain images may contain more than 255 instances. Therefore the third seg channel is needed to decode the instance label. The decoding protocol is defined as:

    labelInst = 256.*int32(gt.seg(:,:,3)) + int32(gt.seg(:,:,2))

The "gt.bdry" field is a 150x1 cell array of sparse HxW matrices containing category-wise boundary ground truth with single pixel width. The ground truth is generated from the masks in gt.seg and should be used in your evaluation. Similar ground truth will also be used for the final evaluation on the test set.

You may, however, generate your own ground truth from either gt.seg or gt.bdry for training purposes. You may also feel free to make use of gt.seg in training your model.

## Submission format to the evaluation server

The structure of your submitted result should EXACTLY follow the following example:

    predictions_boundary/testing/class_001/ADE_val_00000001.png
    predictions_boundary/testing/class_001/ADE_val_00000002.png
        ...
    predictions_boundary/testing/class_001/ADE_val_00003000.png

    predictions_boundary/testing/class_002/ADE_val_00000001.png
    predictions_boundary/testing/class_002/ADE_val_00000002.png
        ...
    predictions_boundary/testing/class_002/ADE_val_00003000.png
        ...
    predictions_boundary/testing/class_150/ADE_val_00000001.png
    predictions_boundary/testing/class_150/ADE_val_00000002.png
        ...
    predictions_boundary/testing/class_150/ADE_val_00003000.png

where subfolders class_001 - class_150 contain the category-wise predicted boundary probability maps for every test image. The boundary maps can either be soft or hard, and must be saved in .png format where 255 indicates probability 1.

## Evaluation protocol

The evaluation follows the same evaluation protocol as the Berkeley Segmentation Dataset and Benchmark (BSDS500), where we apply standard edge thinning to every predicted map, followed by boundary alignment and precession recall computation. Note that image margin pixels (margin size set to 3) will ignored in the evaluation. As a result you may also optionally ignore the margin pixels during training.

Our challenge result will be determined by the F-measure at optimal dataset scale (F-ODS). The evaluation toolkit also provides F-measure at optimal image scale (F-OIS) and average precision (AP) to evaluate your model. For more details, please refer to the following papers:

1. Martin et al., "Learning to detect natural image boundaries using local brightness, color, and texture cues," IEEE Trans. PAMI 2004.

2. Arbelaez et al., "Contour detection and hierarchical image segmentation," IEEE Trans. PAMI 2011.

