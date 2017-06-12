# Instruction for Scene Parsing Task

Scene Semantic Segmentation is to segment the image into object and stuff categories. The task is pixel-wise classification which is similar to semantic segmentation task in Pascal, but the difference is that each pixel in each testing image is required to be classified into some semantic category such as stuff concepts like sky, grass, road or discrete objects like person, car, building. There are 150 semantic categories in total, which cover 89% of all the pixels of all the images.
The data for this task comes from 25K fully annotated images, a subset of the Places2 Database (called ADE20K). Specifically, the challenge data is divided into 20K images for training, 2K images for validation, and 3K images for testing. The evaluation metric is IoU averaged over all the 150 visual concepts.

