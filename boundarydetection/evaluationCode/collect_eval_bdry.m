function resultCat = collect_eval_bdry(resultCatImg)
% Computes the F-measures at both optimal dataset scale (ODS) and optimal
% image scale (OIS)
% Input:
%   resultCatImg: [Threshold, TP, TP+FN, TP, TP+FP] of every image.
% Output:
%   resultCat: 1. [T_ODS, R_ODS, P_ODS, F_ODS, R_OIS, P_OIS, F_OIS, AP]
%              2. P, R and F values at different thresholds of a category
%              3. P, R, F, TP, TP+FN, TP+FP values at different thresholds
%                 of an image

dR = 0.01;
numFile = size(resultCatImg, 1);
AA = resultCatImg{1, 1}; % thresh cntR sumR cntP sumP
thresh = AA(:, 1);
nthresh = numel(thresh);
cntR_total = zeros(nthresh,1);
sumR_total = zeros(nthresh,1);
cntP_total = zeros(nthresh,1);
sumP_total = zeros(nthresh,1);
cntR_max = 0;
sumR_max = 0;
cntP_max = 0;
sumP_max = 0;

% main loop
resultCat = cell(3, 1);
resultCat{3} = cell(numFile, 1);
for idxFile = 1:numFile
    AA  = resultCatImg{idxFile, 1};
    cntR = AA(:, 2);
    sumR = AA(:, 3);
    cntP = AA(:, 4);
    sumP = AA(:, 5);
    
    % accumulate for ODS scores
    cntR_total = cntR_total + cntR;
    sumR_total = sumR_total + sumR;
    cntP_total = cntP_total + cntP;
    sumP_total = sumP_total + sumP;
    
    % accumulate for OIS scores
    R = cntR ./ (sumR + (sumR==0));
    P = cntP ./ (sumP + (sumP==0));
    F = fmeasure(R, P);
    [~, idxOIS] = max(F);
    cntR_max = cntR_max + cntR(idxOIS);
    sumR_max = sumR_max + sumR(idxOIS);
    cntP_max = cntP_max + cntP(idxOIS);
    sumP_max = sumP_max + sumP(idxOIS);
    
    % store image-level scores
    resultCat{3}{idxFile} = [thresh, F, P, R, cntR, sumR, sumP];
end

% compute ODS scores
R = cntR_total ./ (sumR_total + (sumR_total==0));
P = cntP_total ./ (sumP_total + (sumP_total==0));
F = fmeasure(R, P);
[T_ODS, R_ODS, P_ODS, F_ODS] = maxF(thresh, R, P);

% compute OIS scores
R_OIS = cntR_max ./ (sumR_max + (sumR_max==0));
P_OIS = cntP_max ./ (sumP_max + (sumP_max==0));
F_OIS = fmeasure(R_OIS, P_OIS);

% compute average precision
[Ru, indR, ~] = unique(R);
Pu = P(indR);
Ri = 0 : dR : 1;
if numel(Ru)>1,
    P_int1 = interp1(Ru, Pu, Ri);
    P_int1(isnan(P_int1)) = 0;
    AP = sum(P_int1)*dR;
else
    AP = 0;
end

% store category-level scores
resultCat{1, 1} = [T_ODS, R_ODS, P_ODS, F_ODS, R_OIS, P_OIS, F_OIS, AP];
resultCat{2, 1} = [thresh, R, P, F];
end

% compute f-measure fromm recall and precision
function [f] = fmeasure(r,p)
f = 2*p.*r./(p+r+((p+r)==0));
end

% interpolate to find best F and coordinates thereof
function [T_ODS, R_ODS, P_ODS, F_ODS] = maxF(thresh, R, P)
T_ODS = thresh(1);
R_ODS = R(1);
P_ODS = P(1);
F_ODS = fmeasure(R(1),P(1));
for idxThre = 2:numel(thresh),
    for d = linspace(0,1),
        t = thresh(idxThre)*d + thresh(idxThre-1)*(1-d);
        r = R(idxThre)*d + R(idxThre-1)*(1-d);
        p = P(idxThre)*d + P(idxThre-1)*(1-d);
        f = fmeasure(r,p);
        if f > F_ODS,
            T_ODS = t;
            R_ODS = r;
            P_ODS = p;
            F_ODS = f;
        end
    end
end
end
