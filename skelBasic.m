function skel = skelBasic(im,gaussOrder,thres,branch,neighborhood)
%Skeletonize an image with matlab's built in skel function
%

%   INPUT:
%       im - the input image, will attempt to convert color images
%       gaussOrder - the order of the gaussian filter
%       thres - the threshold from 0-256 of data to examine
%       branch - the minimum size of a branch when pruning
%
%   OUTPUT:
%       skel - the skeletonization


if 2 < size(size(im),2)
    warning('Attempting to convert multidimensional image to grayscale')
    img = rgb2gray(im);
elseif size(size(im),2) < 2
    error('Not an image?')
else
    img = im;
end


if 0 < gaussOrder
    imblur = imgaussfilt(img,gaussOrder);
elseif gaussOrder < 0
    error('Negative Gauss order specified');
else
    imblur = img;
end

%{
%if thres1 < 
if thres < 0 
    error('Negative threshold entered');
elseif 256 < thres
    error('Threshold must be <=256');
else
    imbw = imbinarize(imblur,thres/256);
end
%}
T = adaptthresh(imblur,0.5,'ForegroundPolarity','bright','NeighborhoodSize',neighborhood);
imbw = imbinarize(imblur,T);
for i=1:size(im,2)
    for j=1:size(im,1)
       % imbw(j,i)=0;
        if imbw(j,i) == 1 && im(j,i) < thres
            imbw(j,i) = 0;
        end
    end
end
            


if 0 < branch
    skel = bwskel(imbw,'MinBranchLength',branch);
elseif branch < 0
    error('Negative minimum branch specified');
else 
    skel = bwskel(imbw);
end

flag = false;
for i=1:size(skel,2)
    if flag 
        break 
    end
    for j=1:size(skel,1)
        if(skel(j,i) == 1)
            flag = true;
            break
        end
    end
end

if ~flag 
    figure
    subplot(2,2,1), imshow(img);
    subplot(2,2,2), imshow(imblur);
    subplot(2,2,3), imshow(single(imbw));
else
    figure
    subplot(2,2,1), imshow(labeloverlay(img,skel,'Transparency',0));
    subplot(2,2,2), imshow(labeloverlay(imblur,skel,'Transparency',0));
    subplot(2,2,3), imshow(labeloverlay(single(imbw),skel,'Transparency',0));
end

end

