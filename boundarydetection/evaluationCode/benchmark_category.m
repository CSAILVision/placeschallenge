function resultCat = benchmark_category(fileLst, predDir, gtDir, scoreDir, idxCls, nthresh, margin, verbose, showFig)
% Computes the precision recall values for a given category and the
% corresponding F-measure at optimal dataset scale (ODS)
% Input:
%   fileLst  : List of file names to be evluated.
%   predDir  : Directory containing predicted boundaries.
%   gtDir    : Directory containing ground truth boundaries.
%   scoreDir : Directory to put evaluation scores.
%   idxCls   : Current category id.
%   [nthresh]: Number of thresholds applied in evaluation.
%   [margin] : Size of margin to be ignored in evaluation.
%   [verbose]: Flag choose to display image-wise results or not
%   [showFig]: Flag choose to display the predicted boundary of a certain
%              class or not when verbose is on
% Output:
%   resultCat: 1. [T_ODS, R_ODS, P_ODS, F_ODS, R_OIS, P_OIS, F_OIS, AP]
%              2. P, R and F values at different thresholds of a category
%              3. P, R, F, TP, TP+FN, TP+FP values at different thresholds
%                 of an image

if(nargin<6), nthresh = 99; end;
if(nargin<7), margin = 0; end;
if(nargin<8), verbose = false; end;
if(nargin<9), showFig = false; end;

% If results exist, load & skip evaluation. Otherwise, perform evaluation
assert(exist(scoreDir, 'file') == 7)
if(exist(fullfile(scoreDir, ['class_' num2str(idxCls, '%03d') '.mat']), 'file') == 2)
    fprintf('Evaluation result exists. Skipping evaluation.\n')
    load(fullfile(scoreDir, ['class_' num2str(idxCls, '%03d') '.mat']));
else
    resultCatImg = evaluate_imgs(fileLst, predDir, gtDir, idxCls, nthresh, margin);
    resultCat = collect_eval_bdry(resultCatImg);
    save(fullfile(scoreDir, ['class_' num2str(idxCls, '%03d') '.mat']), 'resultCat');
end

if(verbose)
    fprintf('verbose is on. turn verbose off to suppress image-wise outputs.\n')
    if(showFig)
        fprintf('showFig is on. Press on the figure to jump to next one. Turn showFig off to suppress illustration.\n')
        load('objectName150.mat');
    end
    for idxImg = 1:length(resultCat{3})
        % show image-wise evaluated scores on a certain class
        scoreImg = resultCat{3}{idxImg}; % [thre, F, P, R, TP, TP+FN, TP+FP]
        [~, idxOIS] = max(scoreImg(:, 2));
        scoreOIS = scoreImg(idxOIS, :);
        fprintf('Image:%4d  F_OIS:%4.3f  R:%4.3f  P:%4.3f  TP:%5d  TP+FN:%5d  TP+FP:%5d\n', ...
            idxImg, scoreOIS(2), scoreOIS(3), scoreOIS(4), scoreOIS(5), scoreOIS(6), scoreOIS(7));
        % show image-wise predicted boundaries on a certain class
        if(showFig)
            gtLoad = load(fullfile(gtDir, [fileLst{idxImg} '.mat']), 'gt');
            bdryGT = full(double(gtLoad.gt.bdry{idxCls}));
            bdryPred = imread(fullfile(predDir, ['class_' num2str(idxCls, '%03d')], [fileLst{idxImg} '.png']));
            set(gcf, 'Name', [fileLst{idxImg} '  (Press any key or click figure for the next image)'], 'NumberTitle', 'off');
            subaxis(1, 2, 1, 'sh', 0.03, 'sv', 0, 'paddingtop', 0.08, 'margin', 0);
            imshow(bdryGT); title(['GT Class ' num2str(idxCls) ': ' objectNames{idxCls}]);
            subaxis(1, 2, 2, 'sh', 0.03, 'sv', 0, 'paddingtop', 0.08, 'margin', 0);
            imshow(bdryPred); title(['Prediction Class ' num2str(idxCls) ': ' objectNames{idxCls}]);
            waitforbuttonpress;
        end
    end
end
