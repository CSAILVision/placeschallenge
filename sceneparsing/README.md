# Instruction for the Scene Parsing Task

Scene parsing is to segment and parse an image into different image regions associated with semantic categories, such as sky, road, person, and bed. It is similar to semantic segmentation tasks in COCO and Pascal Dataset, but the data is more scene-centric and with a diverse range of object categories. Specifically, the challenge data is divided into 20K images for training, 2K images for validation, and another batch of held-out images for testing. There are in total 150 semantic categories included in the benchmark for evaluation, which include stuffs like sky, road, grass, and discrete objects like person, car, bed. Note that non-uniform distribution of objects occurs in the images, mimicking a more natural object occurrence in daily scenes.

The scene parsing is one of the three scene understanding tasks at the [Places Challenge 2017](http://placeschallenge.csail.mit.edu/).


## Data 

- Download the images at [here](http://placeschallenge.csail.mit.edu/data/ChallengeData2017/images.tar). Images are the same for all the three tasks in Places Challenge 2017.
- Download the scene parsing data at [here](http://placeschallenge.csail.mit.edu/data/ChallengeData2017/sceneparsing.tar). After untarring the image file and annotation file, the directory structure should be similar to the following,

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
    
    annotations_sceneparsing/training/ADE_train_00000001.png
    annotations_sceneparsing/training/ADE_train_00000002.png
        ...
    annotations_sceneparsing/training/ADE_train_00020210.png
        
    annotations_sceneparsing/validation/ADE_val_00000001.png
    annotations_sceneparsing/validation/ADE_val_00000002.png
        ...
    annotations_sceneparsing/validation/ADE_val_00002000.png

In each instance annotation mask, balbalba 

## Submission format to the evaluation server

To evaluate the algorithm on the test set of the benchmark (link: TBD), participants are required to upload a zip file which contains the predicted annotation mask for the given testing images to the evaluation server. The naming of the predicted annotation mask should be the same as the name of the testing images, while the filename extension should be png instead of jpg. For example, the predicted annotation mask for file ADE_test_00000001.jpg should be ADE_test_00000001.png.

Participants should check the zip file to make sure it could be decompressed correctly. 

## Evaluation routines

The performance of the segmentation algorithms will be evaluated by the mean of (1) pixel-wise accuracy over all the labeled pixels, and (2) IoU (intersection over union) avereaged over all the 150 semantic categories. 

    Intersection over Union = (true positives) / (true positives + false positives + false negatives)
    Pixel-wise Accuracy = correctly classifield pixels / labeled pixels
    Final score = (Pixel-wise Accuracy + mean(Intersection over Union)) / 2

## Demo codes

In demoEvaluation.m, we have included our implementation of the standard evaluation metrics (pixel-wise accuracy and IoU) for the benchmark. As mentioned before, we ignore pixels labeled with 0's.

Please change the paths at the begining of the code accordingly to evalutate your own results. While running it correctly, you are expected to see output similar to:

    Mean IoU over 150 classes: 0.1000
    Pixel-wise Accuracy: 100.00%

In this case, we will take (0.1+1.0)/2=0.55 as your final score.

We have also provided demoVisualization.m, which helps you to visualize individual image results.
