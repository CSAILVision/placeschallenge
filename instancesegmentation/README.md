# Instruction for the Instance Segmentation Task in Places Challenge 2017

write what is the instance segmentation. how many categories, where are the lists, etc.

## Data 

- Download the images at http://placeschallenge.csail.mit.edu/data/ChallengeData2017/images.tar. Images are the same for all the three tasks in Places Challenge 2017.
- Download the instance segmentation data at http://placeschallenge.csail.mit.edu/data/ChallengeData2017/instances.tar. After untarring the data file, the directory structure should be similar to the following,

the training images:

    images/training/ADE_train_00000001.jpg
    images/training/ADE_train_00000002.jpg
        ...
    images/training/ADE_train_00020210.jpg

the validation images:
    images/training/ADE_train_00000001.jpg
    images/training/ADE_train_00000002.jpg
        ...
    images/training/ADE_train_00020210.jpg

the testing images:
    images/testing/ADE_test_00000001.jpg
        ...


the corresponding instance annotation masks for the training images and validation images:
    
    annotations_instance/training/ADE_train_00000001.png
    annotations_instance/training/ADE_train_00000002.png
        ...
    annotations_instance/training/ADE_train_00020210.png
        
    annotations_instance/validation/ADE_val_00000001.png
    annotations_instance/validation/ADE_val_00000002.png
        ...
    annotations_instance/validation/ADE_val_00002000.png

In each instance annotation mask, balbalba 

## Submission format to the evaluation server


## Evaluation routines

The performance os the instance segmentation algorithms will be evaluated by xxxx. There are sample evaluation codes yyy.
