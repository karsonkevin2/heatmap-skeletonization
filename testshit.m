function testshit(im, kernel)

img = rgb2gray(im);
[sizeY, sizeX] = size(img);

imgpad = padarray(img,[kernel,kernel],'replicate','both');

avgg = zeros(sizeY,sizeX);
maxx = zeros(sizeY,sizeX);
minn = zeros(sizeY, sizeX);

for x=1:sizeX
    for y=1:sizeY
        temp = imgpad(y:y+2*kernel, x:x+2*kernel); 
        avgg(y,x) = mean(mean(temp));
        maxx(y,x) = max(max(temp));
        minn(y,x) = min(min(temp));
    end
end

out = zeros(sizeY,sizeX);
for x=1:sizeX
    for y=1:sizeY
        if img(y,x) > maxx(y,x)*0.8
            out(y,x) = img(y,x);
        end
    end
end

test = mean(minn,maxx);

avgg = rescale(avgg, 0,1);
maxx = rescale(maxx, 0,1);
minn = rescale(minn, 0,1);
test = rescale(test, 0,1);

subplot(2,2,1), imshow(test)
subplot(2,2,2), imshow(maxx)
subplot(2,2,3), imshow(img)
subplot(2,2,4), imshow(minn)

