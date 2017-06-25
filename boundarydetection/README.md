# Instruction for Semantic Boundary Detection

write what is the semantic boundary detection. how many categories, where are the lists, etc. including some teaser images.

## Data 

- Download the images at [here](http://placeschallenge.csail.mit.edu/data/ChallengeData2017/images.tar). Note that images are the same for all the three tasks in Places Challenge 2017.

- Download the boundary annotation data at [here](http://placeschallenge.csail.mit.edu/data/ChallengeData2017/boundaries.tar). After untarring the image files, the directories should follow the below examples:

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


The corresponding annotation directories should follow the below examples:
    
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

In each boundart annotation mat file, there are variable xxx, yyy. We also provde a python data loader script xxxx to read out the annotation mat files.

## Submission format to the evaluation server


## Evaluation routines

The performance os the instance segmentation algorithms will be evaluated by xxxx. There are sample evaluation codes yyy.
