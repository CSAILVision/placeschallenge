function im = overlayAnno(im, anno)
%% This function encodes label maps into rgb images for better visualization
% im: input image [h, w, 3]
% anno: input annotation [h, w]
    
    % load class names
    load('instanceNames100.mat');
    % set params
    trans = 0.3;
    
    % iterate over each valid instance, compute bbox & names, draw to image
    im = im2double(im);
    Om = anno(:,:,1);
    Oi = anno(:,:,2);
    for i=1:max(Oi(:))
        % set random color
        curColor = random('unif', 0, 1, [1,3]) * 0.8 + 0.2;

        % draw mask
        curMask = (Oi==i);
        im = bsxfun(@times, im, (1 - curMask * trans));
        im = im + bsxfun(@times, curMask * trans, reshape(curColor,1,1,3));

        % insert bbox
        [row, col] = find(curMask);
        curBbox = [min(col(:)), min(row(:)), max(col(:))-min(col(:)), ... 
            max(row(:))-min(row(:))];
        im = insertShape(im, 'Rectangle', curBbox, 'Color', curColor);

        % insert object name
        objIdx = Om(curMask);
        objIdx = objIdx(1);
        im = insertText(im, [min(col(:)), min(row(:))+2], instanceNames(objIdx,:), ...
                'AnchorPoint', 'LeftBottom','BoxOpacity',0,'TextColor','white');
    end

end

