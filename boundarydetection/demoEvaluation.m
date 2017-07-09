% This script demos the evaluation of the predicted boundaries in predDir.
% Make sure you have the corresponding files in both predDir and gtDir.
% Parallel computing with multiple workers is strongly recommended, as
% boundary evaluation can take much time.
close all; clc; clear;
addpath(genpath('evaluationCode'));
addpath(genpath('visualizationCode'));

%% Set directories
gtDir = fullfile('annotations_boundary', 'validation'); % Directory to put ground truth boundaries
predDir = fullfile('predictions_boundary', 'validation'); % Directory to put predicted boundaries
scoreDir = fullfile('result_eval', 'scores'); % Directory to put evaluation scores
plotDir = fullfile('result_eval', 'plots'); % Directory to put evaluation plots

%% Set evaluation parameters
numCls = 150;
margin = 3; % Size of margin to be ignored in evaluation
nthresh = 99; % Number of thresholds
numWorker = 20; % Number of matlab workers for parallel computing
verbose = true; % Choose to display image-wise OIS scores or not
showFig = true; % choose to display the predicted boundary of a certain class or not when verbose is on

%% Perform evaluation
% Make directories for evaluation results
if(~exist(scoreDir, 'file'))
    mkdir(scoreDir);
end
if(~exist(plotDir, 'file'))
    mkdir(plotDir);
end

% Define the set of files to be evaluated
fileLst = dir(fullfile(gtDir, '*.mat'));
fileLst = {fileLst.name};
numFile = length(fileLst);
for idxFile = 1:numFile
    fileLst{idxFile} = fileLst{idxFile}(1:end-4);
end

% Load predefined class names and colors
load('objectName150.mat');
load('color150.mat');

% Make sure parallel pool is created to guarantee correct parfor monitoring
matlabVer = version('-release');
if( str2double(matlabVer(1:4)) > 2013 || (str2double(matlabVer(1:4)) == 2013 && strcmp(matlabVer(5), 'b')) )
    delete(gcp('nocreate'));
    parpool('local', numWorker);
else
    if(matlabpool('size')>0) %#ok<*DPOOL>
        matlabpool close
    end
    matlabpool open 8
end

% Main evaluation loop
for idxCls = 1:numCls
    fprintf('Benchmarking boundaries for category %d: %s\n', idxCls, objectNames{idxCls});
    resultCat = benchmark_category(fileLst, predDir, gtDir, scoreDir, idxCls, nthresh, margin, verbose, showFig);
end

%% Collect evaluation results
fprintf('==== Summary F-ODS ====\n');
F_ODS = zeros(numCls, 1);
for idxCls = 1:numCls
    load(fullfile(scoreDir, ['class_' num2str(idxCls, '%03d') '.mat']))
    F_ODS(idxCls) = resultCat{1}(4);
    fprintf('%3d %16s: %.4f\n', idxCls, objectNames{idxCls}, F_ODS(idxCls));
end
F_ODS_Mean = mean(F_ODS);
fprintf('Mean F-ODS over %d classes: %.4f\n', numCls, F_ODS_Mean);
save(fullfile(scoreDir, 'F_ODS.mat'), 'F_ODS');

%% Plot category-wise F-ODS histogram
fprintf('Plotting f-ods histogram over %d classes\n', numCls);
load(fullfile(scoreDir, 'F_ODS.mat'));
figure('Visible', 'off')
bar(1:length(F_ODS), F_ODS);
ylim([0 1])
xlabel('Category ID')
ylabel('F-ODS Score')
title('F-ODS over 150 Classes')
print(gcf, fullfile(plotDir, 'F_ODS.pdf'),'-dpdf')
close(gcf)

%% Plot PR curves
% plot_pr supports plotting multiple evaluation results on the same figure.
% To do that, input the first two arguments as: {scoreDir1; scoreDir2; ...}
% and {methodName1; methodName2; ...}
plot_pr({scoreDir}, {'baseline'}, numCls, plotDir, objectNames);
