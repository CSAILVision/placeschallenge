% This script demos how to use colorEncode() to visualize predicted
% boundary maps.
% Make sure you have the corresponding files in predDir.
close all; clc; clear;
addpath(genpath('evaluationCode'));
addpath(genpath('visualizationCode'));

% Set directories & parameters
pathImg = fullfile('images', 'validation');
pathGT = fullfile('annotations_boundary', 'validation');
pathPred = fullfile('predictions_boundary', 'validation'); % Directory to put predicted boundaries
pathScore = fullfile('result_eval', 'scores');
numCls = 150;
showCls = false; % Set true to show class-wise boundary maps
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
    bdryPredMax = zeros(height, width);
    for idxCls = 1:numCls        
        % load class-wise gt and predictions
        bdryGT = full(double(gtLoad.gt.bdry{idxCls}));
        bdryPred = im2double(imread(fullfile(pathPred, ['class_' num2str(idxCls, '%03d')], [fileLst{idxFile} '.png'])));
        
        % choose ODS threshold or not
        if(useODS)
            bdryPredIdx = double(bdryPred > threODS(idxCls));
            bdryPred(~bdryPredIdx) = 0;
        else
            bdryPredIdx = double(bdryPred > 0.5);
            bdryPred(~bdryPredIdx) = 0;
        end
        
        % color encoding
        colorCls = squeeze(double(colorEncode(idxCls, colors)))';
        bdryGTVis = bdryGTVis + reshape(bdryGT(:)*colorCls, [height, width, 3]);
        % bdryGTVis = bdryGTVis + double(colorEncode(bdryGT.*idxCls, colors));
        bdryGTSum = bdryGTSum + bdryGT;
        bdryPredVis = bdryPredVis + reshape(bdryPred(:)*colorCls, [height, width, 3]);
        % bdryPredVis = bdryPredVis + repmat(bdryPred, [1 1 3]).*double(colorEncode(idxCls.*ones(height, width), colors));
        bdryPredSum = bdryPredSum + bdryPred;
    end
    bdryGTVis = uint8(bdryGTVis./repmat(bdryGTSum, [1 1 3]));
    bdryPredVis = uint8(bdryPredVis./repmat(bdryPredSum, [1 1 3]));
    
    fprintf('Press any key to the next image')
    if(showCls)
        % plot figures
        for idxCls = 1:numCls
            % load class-wise gt and predictions
            bdryGT = full(double(gtLoad.gt.bdry{idxCls}));
            bdryPred = im2double(imread(fullfile(pathPred, ['class_' num2str(idxCls, '%03d')], [fileLst{idxFile} '.png'])));
            
            set(gcf, 'Name', [fileLst{idxFile} ' Class ' num2str(idxCls)], 'NumberTitle', 'off');
            subplot(231);
            imshow(img); title('Original Image');
            subplot(232);
            imshow(bdryGTVis); title('GT All Classes');
            subplot(233);
            imshow(bdryPredVis); title('Pred All Classes');
            subplot(234);
            imshow(bdryGT); title(['GT Class ' num2str(idxCls)]);
            subplot(235);
            imshow(bdryPred); title(['Pred Class ' num2str(idxCls)]);
            waitforbuttonpress;
        end
    else
        set(gcf, 'Name', [fileLst{idxFile}], 'NumberTitle', 'off');
        subplot(131);
        imshow(img); title('Original Image');
        subplot(132);
        imshow(bdryGTVis); title('GT All Classes');
        subplot(133);
        imshow(bdryPredVis); title('Pred All Classes');
        waitforbuttonpress;
    end
end


