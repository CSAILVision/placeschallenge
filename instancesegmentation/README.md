# Instruction for the Instance Segmentation Task

write what is the instance segmentation. how many categories, where are the lists, etc.

## Data 

- Download the images at [here](http://placeschallenge.csail.mit.edu/data/ChallengeData2017/images.tar). Note that Images are the same for all the three tasks in Places Challenge 2017.
- Download the instance segmentation data at [here](http://placeschallenge.csail.mit.edu/data/ChallengeData2017/instances.tar). After untarring the data file, the directory structure should be similar to the following,

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

## Submission format

The submission file should be a single .zip file containing all the predictions in JSON format:
    
    ADE_test_00000001.json
    ADE_test_00000002.json
        ...


## Evaluation routines
The performance of the instance segmentation algorithms will be evaluated by Average Precision (AP, or mAP), following COCO evaluation metrics. 
For each image, we take at most 256 top-scoring instance masks across all categories.
For each instance mask prediction, we only count it when its IoU with ground truth is above a certain threshold. We take 10 IoU thresholds of 0.50:0.05:0.95 for evaluation. The final AP is averaged across 10 IoU thresholds and 100 categories.

Sample evaluation code can be found at...
