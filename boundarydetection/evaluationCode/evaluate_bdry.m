function [thresh, cntR, sumR, cntP, sumP] = evaluate_bdry(bdryPred, bdryGT, margin, nthresh, thinpb, maxDist)
% Performs alignment between ground truth and predicted boundaries, and
% calculates the precision/recall curve.
% Input:
%	bdryPred: The candidate boundary image. Must be double.
%	bdryGT	 : Ground truth boundaries
%   margin   : Size of margin to be ignored in evaluation.
%   nthresh  : Number of points in PR curve.
%   [thinpb] : Option to apply morphological thinning on predicted boundaries.
%   [MaxDist]: Threshold controlling the maximum mis-alignment distance
%              tolerated. Maximum tolerated distance = MaxDist*ImgDiagSize.
% Output:
%	thresh	 : Vector of threshold values.
%   cntR     : True positive numbers. (TP)
%	sumR     : Condition positive numbers. (TP+FN)
%	cntP     : True positive numbers. (TP)
%   sumP     : Prediction positive numbers. (TP+FP)

if nargin<5, thinpb = true; end
if nargin<6, maxDist = 0.0075; end

%% Ignore evaluation at margin pixels
assert(margin>=0 && abs(round(margin)-margin)<eps, 'Margin size must be non-negative integers.');
bdryPred = bdryPred(1+margin:end-margin, 1+margin:end-margin);
bdryGT = bdryGT(1+margin:end-margin, 1+margin:end-margin);

%% Initialize
%setup thresholds
thresh = linspace(1/(nthresh+1), 1-1/(nthresh+1), nthresh)';

% zero all counts
cntR = zeros(size(thresh));
sumR = zeros(size(thresh));
cntP = zeros(size(thresh));
sumP = zeros(size(thresh));

%% Evaluate at every threshold
% Check whether edge
bdryExist = true;
if(sum(bdryGT(:))==0)
    bdryExist = false;
end

for t = 1:nthresh
    % Threshold the predicted boundary map
    bdryThre = bdryPred>=thresh(t);
    
    % Thin the thresholded prediction to make sure boundaries are standard thickness
    if(thinpb)
        bdryThre = bwmorph(bdryThre, 'thin', inf);
    end
    
    % Perform edge alignment if gt boundary exists, and accumulate cntR
    if(bdryExist)
        % align predicted boundaries and ground truth boundaries
        [match1, match2] = correspondPixels(double(bdryThre), double(bdryGT), maxDist);
        
        % compute recall
        cntR(t) = sum(match2(:)>0);
        sumR(t) = sum(bdryGT(:)>0);
        
        % compute precision
        cntP(t) = sum(match1(:)>0);
        sumP(t) = sum(bdryThre(:)>0);
        
        % perform sanity check
        assert(cntR(t)==cntP(t), 'Matched pixel numbers between predicted boundary and gt not equal.');
    else
        % If boundary does not exist, all predicted positives are false positives
        sumP(t) = sum(bdryThre(:)>0);
    end
end