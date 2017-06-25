% This script demos how to visualize instance annotations
close all; clc; clear;
rng(123);

% change to your dataset root
rootDataset = '.';

% Paths and options
addpath(genpath('visualizationCode'));

% path to image(.jpg) and annotation(.png)
pathImg = fullfile(rootDataset, 'images', 'validation');
pathLab = fullfile(rootDataset, 'annotations_instance', 'validation');

% loop over the dataset
filesLab = dir(fullfile(pathLab, '*.png'));
for i = 1: numel(filesLab)
    % read image
    fileImg = fullfile(pathImg, strrep(filesLab(i).name, '.png', '.jpg'));
    fileLab = fullfile(pathLab, filesLab(i).name);
    im = imread(fileImg);
    anno = imread(fileLab);
    
    % color encoding
    imVis = overlayAnno(im, anno);
    
    % plot
    set(gcf, 'Name', [fileImg ' [Press any key to the next image...]'],  'NumberTitle','off');
    imshow(imVis); title('Image with instance annotations');    
    waitforbuttonpress;
    
end