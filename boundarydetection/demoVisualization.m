% This script demos how to use colorEncode() to visualize predicted
% boundary maps. 
% Make sure you have the corresponding files in predDir.
% To control, press "n" for the next class. Press other key
% or click figure for the next image
close all; clc; clear;
addpath(genpath('evaluationCode'));
addpath(genpath('visualizationCode'));

% Set directories & parameters
pathImg = fullfile('images', 'validation');
pathGT = fullfile('annotations_boundary', 'validation');
pathPred = fullfile('predictions_boundary', 'validation'); % Directory to put predicted boundaries
pathScore = fullfile('result_eval', 'scores');
numCls = 150;
useODS = true; % Set true to use ODS threshold instead of 0.5

% Load optimal class-wise threshold
if(useODS)
    threODS = zeros(numCls, 1);
    for idxCls = 1:numCls
        assert(exist(fullfile(pathScore, ['class_' num2str(idxCls, '%03d') '.mat']), 'file')==2, ...
            'Need to complete and save evaluation before loading the ODS thresholds.')
        scoreLoad = load(fullfile(pathScore, ['class_' num2str(idxCls, '%03d') '.mat']));
        threODS(idxCls) = scoreLoad.resultCat{1}(1);
    end
end

% Find the set of files to be visualized
fileLst = dir(fullfile(pathImg, '*.jpg'));
fileLst = {fileLst.name};
numFile = length(fileLst);
for idxFile = 1:numFile
    fileLst{idxFile} = fileLst{idxFile}(1:end-4);
end

% Load predefined class names and colors
load('objectName150.mat');
load('color150.mat');

% Visualization
for idxFile = 1:numel(fileLst)
    % read image
    img = imread(fullfile(pathImg, [fileLst{idxFile} '.jpg']));
    gtLoad = load(fullfile(pathGT, [fileLst{idxFile} '.mat']), 'gt');
    [height, width, ~] = size(img);
    bdryGTVis = zeros(height, width, 3);
    bdryGTSum = zeros(height, width);
    bdryPredVis = zeros(height, width, 3);
    bdryPredSum = zeros(height, width);

    % visualization
    bdryPredAll = cell(numCls,1);
    for idxCls = 1:numCls        
        % load class-wise gt and predictions
        bdryGT = full(double(gtLoad.gt.bdry{idxCls}));
        bdryPred = im2double(imread(fullfile(pathPred, ['class_' num2str(idxCls, '%03d')], [fileLst{idxFile} '.png'])));
        bdryPredAll{idxCls} = bdryPred;
        
        % choose ODS threshold or not
        if(useODS)
            bdryPred(bdryPred<=threODS(idxCls)) = 0;
        else
            bdryPred(bdryPred<=0.5) = 0;
        end
        
        % color encoding
        colorCls = squeeze(double(colorEncode(idxCls, colors)))';
        bdryGTVis = bdryGTVis + reshape(bdryGT(:)*colorCls, [height, width, 3]);
        bdryGTSum = bdryGTSum + bdryGT;
        bdryPredVis = bdryPredVis + reshape(bdryPred(:)*colorCls, [height, width, 3]);
        bdryPredSum = bdryPredSum + bdryPred;
    end
    bdryGTVis = uint8(bdryGTVis./repmat(bdryGTSum, [1 1 3]));
    bdryPredVis = uint8(bdryPredVis./repmat(bdryPredSum, [1 1 3]));
    
    % visualization
    fprintf('Press "n" for the next class. Press other key or click figure for the next image\n')
    for idxCls = 1:numCls
        % load class-wise gt and predictions
        bdryGT = full(double(gtLoad.gt.bdry{idxCls}));

        % plot figures
        set(gcf, 'Name', [fileLst{idxFile} '  (Press "n" for the next class. Press other key or click figure for the next image)'], 'NumberTitle', 'off');
        subaxis(2, 3, 1, 'sh', 0.03, 'sv', 0, 'paddingtop', 0.08, 'margin', 0);
        imshow(img); title('Original Image');
        subaxis(2, 3, 2, 'sh', 0.03, 'sv', 0, 'paddingtop', 0.08, 'margin', 0);
        imshow(bdryGTVis); title('GT All Classes');
        subaxis(2, 3, 3, 'sh', 0.03, 'sv', 0, 'paddingtop', 0.08, 'margin', 0);
        imshow(bdryPredVis); title('Pred All Classes');
        subaxis(2, 3, 4, 'sh', 0.03, 'sv', 0, 'paddingtop', 0.08, 'margin', 0);
        imshow(bdryGT); title(['GT Class ' num2str(idxCls) ': ' objectNames{idxCls}]);
        subaxis(2, 3, 5, 'sh', 0.03, 'sv', 0, 'paddingtop', 0.08, 'margin', 0);
        imshow(bdryPredAll{idxCls}); title(['Prediction Class ' num2str(idxCls) ': ' objectNames{idxCls}]);
        
        % press "n" for next class, otherwise jump to next image
        w = waitforbuttonpress;
        if(w==1)
            key = get(gcf,'currentcharacter');
            if(~strcmp(key, 'n'))
                break;
            end
        else
            break;
        end
    end
end


