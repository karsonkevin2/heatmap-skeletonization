%https://en.wikipedia.org/wiki/Canny_edge_detector
%https://medium.com/strava-engineering/the-global-heatmap-now-6x-hotter-23fc01d301de
%https://en.wikipedia.org/wiki/Bresenham%27s_line_algorithm
%https://en.wikipedia.org/wiki/Histogram_equalization
%https://developer.mozilla.org/en-US/docs/Web/SVG/Element/polyline
%https://www.w3schools.com/graphics/svg_intro.asp

%Clear old variables
clear all

thres = 100;

%Read in image w/ pixel to pixel scale
imc = imread("stravaScaled.png");

%Convert from colorscale to grayscale
img = rgb2gray(imc);

%Apply first order Gaussian filter
imblur = imgaussfilt(img,1);

%Compute gradient
[Gmag, Gdir] = imgradient(imblur,'prewitt');
%sobel

%Apply appropriate scaling
Gmag = im2uint8(rescale(Gmag, 0, 1));
dir = round(Gdir/180*4)*180/4;
Gdir8 = im2uint8(rescale(dir, 0, 1));
Gdir = im2uint8(rescale(Gdir, 0, 1));

pan=size(imblur,1);
leb=size(imblur,2);
BW = zeros(pan, leb);

%imblur = img;
    for i=1+1:pan-1
        for j=1+1:leb-1
            %threshold for data
            if(imblur(i,j) > 5)
                if (dir(i,j)==0 || dir(i,j)==180 || dir(i,j)==-180)
                    BW(i,j) = (imblur(i,j) == max([imblur(i,j), imblur(i,j+1), imblur(i,j-1)]));
                elseif (dir(i,j)==45 || dir(i,j)==-135)
                    BW(i,j) = (imblur(i,j) == max([imblur(i,j), imblur(i+1,j-1), imblur(i-1,j+1)]));
                elseif (dir(i,j)==90 || dir(i,j)==-90)
                    BW(i,j) = (imblur(i,j) == max([imblur(i,j), imblur(i+1,j), imblur(i-1,j)]));
                elseif (dir(i,j)==135 || dir(i,j)==45)
                    BW(i,j) = (imblur(i,j) == max([imblur(i,j), imblur(i+1,j+1), imblur(i-1,j-1)]));
                end
            end
        end
    end


%alternate approach
%flip threshold
Gmagg = im2bw(Gmag, 40/256);
Gmagg = imcomplement(Gmagg);
Gmagskel = bwskel(Gmagg,'MinBranchLength',10);
Gmagskel2 = Gmagskel;
for i=1:pan
    for j=1:leb
        %threshold for data
        if (imblur(i,j) < 30 && Gmagskel(i,j) == 1)
            Gmagskel2(i,j) = 0;
        end
    end
end

skel = skelBasic(img,1,30,10);

% fix skel
imgay = skel + Gmagskel2 + BW;

imshow(labeloverlay(imc,Gmagskel2,'Transparency',0))

%plot

%{
figure
subplot(3,4,1), imshow(imc)
subplot(3,4,2), imshow(img)
subplot(3,4,3), imshow(imblur)
subplot(3,4,4), imshow(Gmag)
subplot(3,4,5), imshow(Gdir)
subplot(3,4,6), imshow(Gdir8)
subplot(3,4,7), imshow(BW)
subplot(3,4,8), imshow(Gmagg)
subplot(3,4,9), imshow(Gmagskel)
subplot(3,4,10), imshow(Gmagskel2)
subplot(3,4,11), imshow(skel)
subplot(3,4,12), imshow(imgay)
%}
