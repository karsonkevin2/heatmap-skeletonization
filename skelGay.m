function skeltest = skelGay(im, varargin)
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
%       'thres' - DEFAULT=0 - [0,255] - minimum value threshold 
%
%   OUTPUT:
%       skeltest - the skeleton bitmap


close all

%flag states
padsize = -1;
blur = -1;
recurse = -1;
theta = -1;
thresh = -1;

if 2 < size(size(im),2)
    warning('Attempting to convert multidimensional image to grayscale')
    img = rgb2gray(im);
elseif size(size(im),2) < 2
    error('Not an image?')
else
    img = im;
end
img = rescale(img);
[sizeY, sizeX] = size(img);

if 1 < nargin
    n = 1;
    while n < nargin
        if strcmp(varargin(n), 'padsize') 
            padsize = cell2mat(varargin(n+1));
            if rem(padsize,1) ~= 0
                warning('Rounding fractional padding');
                padsize = round(padsize);
            end
            if padsize < 0
                error('Pad size must be a posotive integer');
            end
            ps=padsize;
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
        else
            error('Invalid input parameter');
        end
        
        n = n+2;
    end
end

if padsize == -1
    padsize = 1;
    ps = 1;
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
    thresh = 3;
end


if 0 < blur
    imblur = imgaussfilt(img,blur);
elseif blur == 0
    imblur = img;
end


%TODO sobel vs prewitt
[Gmag, Gdir] = imgradient(imblur,'sobel');

Gmag = im2uint8(rescale(Gmag, 0, 1));
dir = round(Gdir/180*4)*180/4;
dirfag = round(Gdir/180*4);
Gdir8 = im2uint8(rescale(dir, 0, 1));
Gdir2 = im2uint8(rescale(Gdir, 0, 1));


%{
for x=1:sizeX
    for y=1:sizeY
        if dirfag(y,x) == -4
            dirfag(y,x) = 4
        end
    end
end
%}

%{
imgpad = padarray(img,[1,1],'replicate','both');
dirX = zeros(sizeY,sizeX);
dirY = zeros(sizeY,sizeX);
opy = single([1 1 1; 0 0 0; -1 -1 -1]);
opX = single([-1 0 1; -1 0 1; -1 0 1]);
for x=1:size(img,2)
    for y=1:size(img,1)
        kernel = single(imgpad(y-1+1:y+1+1,x-1+1:x+1+1));
        dirX(y,x) = sum(sum(kernel .* opX));
        dirY(y,x) = sum(sum(kernel .* opY));
    end
end
%}

%impossible val
%TODO remove 999 padding
dirPad = padarray(Gdir,[ps ps],999,'both');
valPad = padarray(imblur,[ps ps],-1,'both');

skel = zeros(sizeY,sizeX);

for y=1:sizeY
    for x=1:sizeX
        magval = imblur(y,x);
        dirval = Gdir(y,x);
        dir180 = mod(dirval+180,360);
        
        ii=-ps;
        while ii<=ps
            jj=-ps;
            while jj<=ps
                magadj = valPad(y + jj + ps, x + ii + ps);
                diradj = dirPad(y + jj + ps, x + ii + ps);
                
%TODO validate < vs <= &&
                %if diradj~=999 && diradj~=0 && dirval~=0
                if diradj~=999
               
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




%{
for x=1:sizeX
    for y=1:sizeY
        if dirfag(y,x) == -4
            dirfag(y,x) = 4
        end
    end
end
%}

%{
imgpad = padarray(img,[1,1],'replicate','both');
dirX = zeros(sizeY,sizeX);
dirY = zeros(sizeY,sizeX);
opy = single([1 1 1; 0 0 0; -1 -1 -1]);
opX = single([-1 0 1; -1 0 1; -1 0 1]);
for x=1:size(img,2)
    for y=1:size(img,1)
        kernel = single(imgpad(y-1+1:y+1+1,x-1+1:x+1+1));
        dirX(y,x) = sum(sum(kernel .* opX));
        dirY(y,x) = sum(sum(kernel .* opY));
    end
end
%}

%impossible val
%dirPad = padarray(dir,[ps ps],999,'both');
%valPad = padarray(img,[ps ps],-1,'both');

%skel = zeros(size(img));

%{
for y=1:size(img,1)
    for x=1:size(img,2)
        dirval = dir(y,x);
        valhere = img(y,x);
        
        if dirval==45 || dirval==90 || dirval==135
            direy = -1;
        elseif dirval==-45 || dirval==-90 || dirval==-135
            direy = 1;
        else
            direy = 0;
        end
        
        if dirval==-45 || dirval==0 || dirval==45
            direx = 1;
        elseif dirval==135 || dirval==180 || dirval==-180 || dirval==-135
            direx = -1;
        else
            direx = 0;
        end
        
        %diradj = dirPad(y + direy + 1, x + direx + 1);
        flagg = false;
        for ii=-ps:ps
            for jj=-ps:ps
                diradj = dirPad(y + jj + ps, x + ii + ps);
                valadj = valPad(y + jj + ps, x + ii + ps);

                if dirval == 0
                    if diradj==180 || diradj==-180 || diradj==135 || diradj==-135
                        flagg=true;
                        %skel(y,x) = 1;
                    end
                elseif dirval == 45
                    if diradj==-135 || diradj==-90 || diradj==-180 || diradj==180
                        flagg=true;
                        %skel(y,x) = 1;
                    end
                elseif dirval == 90
                    if diradj==-90 || diradj==-45 || diradj==-135
                        flagg=true;
                        %skel(y,x) = 1;
                    end
                elseif dirval == 135
                    if diradj==-45 || diradj==0 || diradj==-90
                        flagg=true;
                        %skel(y,x) = 1;
                    end
                elseif dirval == 180 || dirval == -180
                    if diradj==0 || diradj==45 || diradj==-45
                        flagg=true;
                        %skel(y,x) = 1;
                    end
                elseif dirval == -135
                    if diradj==45 || diradj==90 || diradj==0
                        flagg=true;
                        %skel(y,x) = 1;
                    end
                elseif dirval == -90
                    if diradj==90 || diradj==45 || diradj==135
                        flagg=true;
                        %skel(y,x) = 1;
                    end
                elseif dirval == -45
                    if diradj==135 || diradj==180 || diradj==-180 || diradj==90
                        flagg=true;
                        %skel(y,x) = 1;
                    end
                end
        
        if flagg == true %&& valadj < valhere
            skel(y,x) = 1;
        end
            
            end
        end
        
        
        %for j=-1:1
        %    for i=-1:1
         %       if j~=0 && i~=0
          %          dirNew = dirPad(y+j+1,x+i+1);
           %         if (dirVal==0 && dirNew==180) || (dirVal==0 && dirNew==-180) || (dirVal==45 && dirNew==-135) || (dirVal==-45 && dirNew ==135) || (dirVal==90 && dirNew ==-90) || (dirVal==-90 && dirNew==90) || (dirVal==135 && dirNew==-45) || (dirVal==-135 && dirNew==45) || (dirVal==180 && dirNew==0) || (dirVal==-180 && dirNew==0)
            %            skel(y,x) = 1;
             %           skel(y+j,x+i) = 1;
              %      end
               % end
            %end
        %end
    end
end
%}

beep = im2bw(imblur,thresh/256);
skel = skel .* beep;

skelpad = padarray(skel,[1,1],0,'both');
skelpadc = skelpad;

if 0 < recurse
    for x=1:sizeX
        for y=1:sizeY
            if skelpad(y+1,x+1) == 1
                count8 = -1;
                for i=-1:1
                    for j=-1:1
                        if skelpad(y+1+j,x+1+i) == 1
                            count8 = count8 + 1;
                        end
                    end
                end
                if count8 == 0;
                    skelpad(y+1,x+1) = 0;
                end
            end
        end
    end
end

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

%figure
%imshowpair(skelpadc,skelpad)

skelc = skel;
skel = skelpad(2:sizeY+1,2:sizeX+1);


%{
figure
subplot(2,2,1), imshow(skel)
subplot(2,2,2), imshow(Gdir8)
subplot(2,2,3), imshow(img)
subplot(2,2,4), imshow(imblur)
%}

skeltest = bwskel(logical(skel));

%{
beep = im2bw(img,thresh/256);
skeltest = skeltest .* beep;
%}

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


figure
imshowpair(skel,skeltest);

figure
imshowpair(skeltest,im)

figure
imshowpair(Gdir,skeltest)

figure
imshowpair(Gdir,skel)

%figure
%imtool(skeltest)
%figure
%imshowpair(skelc,img)
end

