function [resultCatImg] = evaluate_imgs(fileLst, predDir, gtDir, idxCls, nthresh, margin)
% Computes the precision recall values for every image
% Input:
%   fileLst  : List of file names to be evluated.
%   predDir  : Directory containing predicted boundaries.
%   gtDir    : Directory containing ground truth boundaries.
%   idxCls   : Current category id.
%   [nthresh]: Number of thresholds applied in evaluation.
%   [margin] : Size of margin to be ignored in evaluation.
% Output:
%   resultCatImg: [Threshold, TP, TP+FN, TP, TP+FP] of every image.

numFile = length(fileLst);
resultCatImg = cell(numFile, 1);
parfor_progress(numFile); % Initialize parfor monitoring
parfor idxFile = 1:numFile
    % Read predicted boundary
    assert(exist(fullfile(predDir, ['class_' num2str(idxCls, '%03d')], [fileLst{idxFile} '.png']), 'file') > 0, ...
        'Failed to load predicted boundaries. Files do not exist.')
    bdryPred = double(imread(fullfile(predDir, ['class_' num2str(idxCls, '%03d')], [fileLst{idxFile} '.png'])))./255;
    
    % Load ground truth boundary
    assert(exist(fullfile(gtDir, [fileLst{idxFile} '.mat']), 'file') > 0, ...
        'Failed to load ground truth files. Files do not exist.')
    gtLoad = load(fullfile(gtDir, [fileLst{idxFile} '.mat']), 'gt');
    bdryGT = full(double(gtLoad.gt.bdry{idxCls}));
    
    % Perform evaluation
    [thresh, cntR, sumR, cntP, sumP] = evaluate_bdry(bdryPred, bdryGT, margin, nthresh);
    resultCatImg{idxFile, 1} = [thresh, cntR, sumR, cntP, sumP];
    
    % Monitor the parfor progress
    parfor_progress();
end
parfor_progress(0); % Clear parfor monitoring