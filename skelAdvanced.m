function skeltest = skelAdvanced(im, varargin)
%Skeletonizes a traffic heatmap

%INPUT:
%   im - the image
%   VARARGIN - specify arguments as key value pairs, none required
%       'padsize' - DEFAULT=1 - [0,infinity) - When searching for ridges, 
%           the neighborhood to consider, padsize=1 would refer to a 3x3 
%           neighborhood, padsize=0 is 1x1 and padsize=2 a 5x5
%       'blur' - DEFAULT=1 - [0,infinity) - the order of the Gaussian filter applied
%       'recurse' - DEFAULT=5 - [0,infinity) - number of times to parse 
%           the image when searching for holes and other features which 
%           will affect the final result
%       'theta' - DEFAULT=120 - [0,180] - the +/- variation in opposing 
%           angle when identifying ridges. theta=10 would look for very 
%           straight ridge, theta = 90 would identify ridges up to 90 off 
%           the opposite, while 120 looks for even minor changes
%       'thresh' - DEFAULT=3 - [0,255] - minimum value threshold 
%       'minSize' - DEFAULT=25 - [1,infinity) - the minimum size of regions
%           to be considered for hysterisis
%       'render' - DEFAULT=1 - {0,1} - whether to render the intermediate 
%           images
%       'branch' - DEFAULT=3 - [0,infinity) - the minimum branch length
%           kept while skeletonizing
%
%   OUTPUT:
%       skeltest - the skeleton bitmap


close all

%flag states
padSize = -1;
blur = -1;
recurse = -1;
theta = -1;
thresh = -1;
minSize = -1;
render = -1;
branch = -1;

if 2 < size(size(im),2)
    warning('Attempting to convert multidimensional image to grayscale')
    imGray = rgb2gray(im);
elseif size(size(im),2) < 2
    error('Not an image?')
else
    imGray = im;
end

imGray = rescale(imGray);
[sizeY, sizeX] = size(imGray);

if 1 < nargin
    n = 1;
    while n < nargin
        if strcmp(varargin(n), 'padsize') 
            padSize = cell2mat(varargin(n+1));
            if rem(padSize,1) ~= 0
                warning('Rounding fractional padding');
                padSize = round(padSize);
            end
            if padSize < 0
                error('Pad size must be a posotive integer');
            end
        elseif strcmp(varargin(n), 'blur')
            blur = cell2mat(varargin(n+1));
            if blur < 0
                error('Negative Gauss order specified');
            end
        elseif strcmp(varargin(n), 'recurse')
            recurse = cell2mat(varargin(n+1));
            if recurse < 0
                error('Negative recurse number specified');
            end
            if rem(recurse,1) ~= 0
                warning('Rounding fractional recurse number');
                recurse = round(recurse);
            end
        elseif strcmp(varargin(n), 'theta')
            theta = cell2mat(varargin(n+1));
            if theta < 0 
                error('Theta must be non-negative');
            end
            if 180 < theta
                error('Theta must be <= 180');
            end
        elseif strcmp(varargin(n), 'thresh')
            thresh = cell2mat(varargin(n+1));
            if thresh < 0
                error('Threshhold must be non-negative');
            end
            if 255 < thresh
                error('Threshold must be less than 256');
            end
            if rem(thresh,1) ~= 0
                warning('Rounding fractional threshold number');
                thresh = round(thresh);
            end      
        elseif strcmp(varargin(n), 'minSize')
            minSize = cell2mat(varargin(n+1));
            if minSize < 1
                error('minSize must be posotive');
            end
            if rem(thresh,1) ~= 0
                warning('Rounding fractional minSize');
                minSize = round(minSize);
            end
        elseif strcmp(varargin(n), 'render')
            render = cell2mat(varargin(n+1));
            if ~(isa(render,'numeric') || isa(render,'float') || isa(render,'integer'))
                error('Enter render as either 1 (true) or 0 (false)');
            elseif render ~= 0 && render ~= 1
                error('Enter render as either 1 (true) or 0 (false)');           
            else
                %render = (boolean)render;
            end
        elseif strcmp(varargin(n), 'branch')
            branch = cell2mat(varargin(n+1));
            if branch < 0
                error('minSize must be nonnegative');
            end
            if rem(branch,1) ~= 0
                warning('Rounding fractional branch');
                branch = round(branch);
            end
        else
            error('Invalid input parameter');
        end
        
        n = n+2;
    end
end

if padSize == -1
    padSize = 1;
end
if blur == -1
    blur = 1;
end
if recurse == -1
    recurse = 5;
end
if theta == -1
    theta = 120;
end
if thresh == -1
    thresh = 10;
end
if minSize == -1
    minSize = 25;
end
if render == -1
    render = 1;
end
if branch == -1
    branch = 3;
end

if render
    figure
    imshow(im)
    title('original image')
end
if render
figure
imshow(imGray)
title('grayscale image')
end

imMask = imbinarize(imGray,thresh/256);
imGray = imGray .* imMask;

if 0 < blur
    imBlur = imgaussfilt(imGray,blur);
elseif blur == 0
    imBlur = imGray;
end

if render
    figure
    imshow(imBlur)
    title('Blurred image')
end

imblur1 = imBlur;
imMask = imbinarize(imBlur,thresh/256);
imBlur = imBlur .* imMask;

[Gmag1, Gdir1] = imgradient(imblur1,'sobel');
[Gmag, Gdir] = imgradient(imBlur,'sobel');

if render
    figure
    imshowpair(Gdir,Gdir1,'diff')
    title('Removed low intensity areas');
end

for x=1:sizeX
    for y=1:sizeY
        if Gmag(y,x) == 0
            Gdir(y,x) = -1;
        end
    end
end

%Gmag = im2uint8(rescale(Gmag, 0, 1));
dir = round(Gdir/180*4)*180/4;
%dirfag = round(Gdir/180*4);
%Gdir8 = im2uint8(rescale(dir, 0, 1));
%Gdir2 = im2uint8(rescale(Gdir, 0, 1));

%impossible val
%TODO remove 999 padding
dirPad = padarray(Gdir,[padSize padSize],-1,'both');
valPad = padarray(imBlur,[padSize padSize],-1,'both');

skel = zeros(sizeY,sizeX);

for y=1:sizeY
    for x=1:sizeX
        magval = imBlur(y,x);
        dirval = Gdir(y,x);
        dir180 = mod(dirval+180,360);
        
        ii=-padSize;
        while ii<=padSize
            jj=-padSize;
            while jj<=padSize
                magadj = valPad(y + jj + padSize, x + ii + padSize);
                diradj = dirPad(y + jj + padSize, x + ii + padSize);
                
%TODO validate < vs <= &&
                if diradj~=-1 && dirval~=-1
               
                    if 360 <= (dir180 + theta)
                        
                        if (mod(dirval+180-theta,360) <= mod(diradj,360)) || (mod(diradj,360) <= mod(dirval+180+theta,360))
                           
                            if magadj <= magval
                                skel(y,x) = 1;
                            end
                        end
                    elseif (dir180 - theta) < 0
                        
                        if mod(dirval+180-theta,360) <= mod(diradj,360) || mod(diradj,360) <= mod(dirval+180+theta,360)
                            
                            if magadj <= magval
                                skel(y,x) = 1;
                            end
                        end
                    else
                        
                        if (mod(dirval+180-theta,360) <= mod(diradj,360)) && (mod(diradj,360) <= mod(dirval+180+theta,360))
                          
                            if magadj <= magval
                                skel(y,x) = 1;
                            end
                        end
                    end
                end
                jj = jj+1;
                if jj==0
                    jj = jj+1;
                end
            end
            ii = ii+1;
            if ii==0
                ii = ii+1;
            end
        end
          
    end
end

if render
    figure
    imshowpair(Gdir,skel)
    title('Identified ridge/valleys')
end

[imLabel,regionCount] = bwlabel(skel);
connectSum = sum(bsxfun(@eq,imLabel(:),1:regionCount));

skelCopy = skel;
for i=1:regionCount
    if connectSum(i) < minSize
        [r,c] = find(imLabel==i);
        for n=1:length(r)
            skel(r(n),c(n)) = 0;
        end
    end
end

if render
    figure
    imshowpair(skel,skelCopy);
    title('Removed small regions')
end

skelpad = padarray(skel,[1,1],0,'both');
skelpadc = skelpad;

%Fill in some regions
for asdf=1:recurse
    for x=1:sizeX
        for y=1:sizeY
            count4 = 0;
            if skelpad(y,x+1)==1
                count4 = count4 + 1;
            end
            if skelpad(y+2,x+1)==1
                count4 = count4 + 1;
            end
            if skelpad(y+1,x+2)==1
                count4 = count4 + 1;
            end
            if skelpad(y+1,x)==1
                count4 = count4 + 1;
            end

            if 3 <= count4
                skelpad(y+1,x+1) = 1;
            end

        end
    end
end

if render
    figure
    imshowpair(skelpadc,skelpad)
    title('Filled holes')
end

skel = skelpad(2:sizeY+1,2:sizeX+1);

skeltest = bwskel(logical(skel), 'MinBranchLength', branch);
skeltest1 = skeltest;

if render
    figure
    imshowpair(skel,skeltest)
    title('skeletonization')
end

skeltestpad = padarray(skeltest,[1,1],1,'both');

for x=1:sizeX
    for y=1:sizeY
        if skeltestpad(y+1,x+1) == 1
            count = -1;
            for i=-1:1
                for j=-1:1
                    if skeltestpad(y+j+1,x+i+1) == 1
                        count = count + 1;
                    end
                end
            end
            if count == 1
                xn = x;
                yn = y;
                while 1
                    dirv = dir(yn, xn);
                    
                    if dirv == 0
                        xn = xn + 1;
                    elseif dirv == 45
                        xn = xn + 1;
                        yn = yn - 1;
                    elseif dirv == 90
                        yn = yn - 1;
                    elseif dirv == 135
                        xn = xn - 1;
                        yn = yn - 1;
                    elseif dirv == 180 || dirv == -180
                        xn = xn - 1;
                    elseif dirv == -135
                        xn = xn - 1;
                        yn = yn + 1;
                    elseif dirv == -90
                        yn = yn + 1;
                    elseif dirv == -45
                        xn = xn + 1;
                        yn = yn + 1;
                    end
                    
                    if skeltestpad(yn+1,xn+1) == 1
                        break
                    end
                    skeltestpad(yn+1,xn+1) = 1;
                end
            end
        end
    end
end
skeltest = skeltestpad(2:sizeY+1,2:sizeX+1);

if render
    figure
    imshowpair(skeltest,skeltest1)
    title('Hysterisis')
end

figure
imshowpair(skeltest,im)
title('Skeletonization')

%figure
%imtool(skeltest)

end

