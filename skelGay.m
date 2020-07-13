function skeltest = skelGay(im, padsize, blur, recurse, theta, thresh)
close all
%default,
% im required 
%   im
% padsize 1 
%   how localized an edge must be
% blur 1
%   helps with low intensity and high intesnsity regions
% recurse 3
%   reduces small loops in skeletonization
% theta 120
%   how well defined a line must be


if rem(padsize,1) ~= 0
    warning('rounding fractional padding');
    padsize = round(padsize);
end
if padsize < 0
    error('Pad size must be a posotive integer');
end
ps=padsize;

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

if 0 < blur
    imblur = imgaussfilt(img,blur);
elseif blur < 0
    error('Negative Gauss order specified');
else
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

skel = zeros(size(img));


for y=1:size(img,1)
    for x=1:size(img,2)
        magval = imblur(y,x);
        dirval = Gdir(y,x);
        dir180 = mod(dirval+180,360);
                
        for ii=-ps:ps
            for jj=-ps:ps
                magadj = valPad(y + jj + ps, x + ii + ps);
                diradj = dirPad(y + jj + ps, x + ii + ps);
                
%TODO validate < vs <= &&
                %if diradj~=999 && diradj~=0 && dirval~=0
                if diradj~=999 && ~isequal([ii,jj],[0,0])
               
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

skelpad = padarray(skel,[1,1],0,'both');
skelpadc = skelpad;
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

beep = im2bw(img,thresh/256);
skeltest = skeltest .* beep;


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
imshowpair(skeltest,imblur)

figure
imshowpair(Gdir,skeltest)

figure
imshowpair(Gdir,skel)

%figure
%imtool(skeltest)
%figure
%imshowpair(skelc,img)
end

