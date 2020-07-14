function imgArray = readWebTiles(latitude,longitude,zoom,tileSize,pad,url)
%Reads a map area from an online tile server
%
%OBEY THE TILE SERVER USAGE POLICY
%
%   EXAMPLE
%       imgArray = readWebTiles(41.661, -91.536, 15, 256, 2, 'https://a.tile.openstreetmap.org/{zoom}/{x}/{y}.png');
%       'https://heatmap-external-a.strava.com/tiles-auth/all/hot/{zoom}/{x}/{y}.png?Key-Pair-Id=APKAIDPUN4QMG7VUQPSA&Policy=eyJTdGF0ZW1lbnQiOiBbeyJSZXNvdXJjZSI6Imh0dHBzOi8vaGVhdG1hcC1leHRlcm5hbC0qLnN0cmF2YS5jb20vKiIsIkNvbmRpdGlvbiI6eyJEYXRlTGVzc1RoYW4iOnsiQVdTOkVwb2NoVGltZSI6MTU5NTE4NzMzM30sIkRhdGVHcmVhdGVyVGhhbiI6eyJBV1M6RXBvY2hUaW1lIjoxNTkzOTYzMzMzfX19XX0_&Signature=k8F3Iz4oM6TPmu~tI5t9UXprYJdVYSalyIX~2bNPPv2BP6q8SfB2Bi-u0wk0m93ir4YGHqLTnjuwu2XD99T0Eo23VqtsbdifscBChgLvK78SORqHQM2NJ9xBzIzgo9fn8~~9ICgPpIkYZZ177a-oFLA8Zwma~T0o4yt1~6hqvqjMag770izGd980Umu~MYjxa7L7yVBLBO0CMbw1MCd3v4UjdITzmZQXNdDL8Dd8Y8nPhhv~LJncSDJC1td4ADWlsWNZwnOxXjvIZMT3k4Y5minLjuPtpksLHyvJ~3AIWs7LEqcM7vUbrXsHh~sc3NXDeWK2H62uhlYFA9Ugip~-cw__');
%
%   INPUT:
%       latitude - the latitude of the desired location 
%           (-90,90) in degrees
%       longitude - the longitude of the desired location
%           [-180,180] in degrees
%       zoom - the level of zoom
%           [0,infinity)
%       tileSize - the resolution of the tile in pixels
%           probably either 256 or 512
%       pad - the amount of tile to include from the center, ie 2 would pad
%           by 2 in each direction for a 5x5 grid
%           [0,infinity)
%       url - the url of the tile server, formatted with wildcards
%           surrounded by curly brackets, variables x, y, zoom

%https://wiki.openstreetmap.org/wiki/Tiles


if latitude <= -90 || 90 <= latitude
    error('latitude must be between (-90,90) degrees');
end

if longitude < -180 || 180 < longitude
    error('longitude must be between [-180,180] degrees');
end

if zoom < 0
    error('zoom must be non-negative');
end
if rem(zoom,1) ~= 0
    error('zoom must be an integer');
end

if tileSize < 1 
    error('tile size must be an posotive number');
end
if rem(tileSize,1) ~= 0
    error('tile size must be an integer');
end

if pad < 0
    error('Pad must be non-negative');
end
if rem(pad,1) ~= 0
    error('pad must be an integer');
end

start=1;
count=1;
count2=1;

for i=1:length(url)
    if url(i) == '{'
        subs = url(start:i-1);
        
        if count == 1
            s1 = subs
        elseif count == 2
            s2 = subs
        elseif count == 3
            s3 = subs
        else
            error('Illegal formatting');
        end
        
        start = i+1;
        count = count + 1;
    end
    if url(i) == '}'
        subs = url(start:i-1);
        if subs == 'x'
            if count2 == 1
                xs = 1;
            elseif count2 == 2
                xs = 2;
            elseif count2 == 3
                xs = 3;
            else
                error('Illegal formatting');
            end
        elseif subs == 'y'
            if count2 == 1
                ys = 1;
            elseif count2 == 2
                ys = 2;
            elseif count2 == 3
                ys = 3;
            else
                error('Illegal formatting');
            end
        elseif subs == 'zoom'
            if count2 == 1
                zs = 1;
            elseif count2 == 2
                zs = 2;
            elseif count2 == 3
                zs = 3;
            else
                error('Illegal formatting');
            end
        else
            error('Illegal formatting');
        end
        
        start = i+1;
        count2 = count2 +1;
    end
end

s4 = url(start:length(url))

[tileX, tileY] = EPSG3857(latitude,longitude,zoom);
    
imgArray = zeros(tileSize*(1+pad*2),tileSize*(1+pad*2));

for i=-pad:pad
    for j=-pad:pad
        x = i + tileX;
        y = j + tileY;
       
        if xs==1 && ys==2 && zs==3
            url = s1 + string(x) + s2 + string(y) + s3 + string(zoom) + s4;
        elseif xs==1 && ys==3 && zs==2 
            url = s1 + string(x) + s2 + string(zoom) + s3 + string(y) + s4;
        elseif xs==2 && ys==1 && zs==3
            url = s1 + string(y) + s2 + string(x) + s3 + string(zoom) + s4;           
        elseif xs==2 && ys==3 && zs==1
            url = s1 + string(zoom) + s2 + string(x) + s3 + string(y) + s4;
        elseif xs==3 && ys==1 && zs==2
            url = s1 + string(y) + s2 + string(zoom) + s3 + string(x) + s4;
        elseif xs==3 && ys==2 && zs==1
            url = s1 + string(zoom) + s2 + string(y) + s3 + string(x) + s4;
        end
                
        
        imgArray(tileSize*(j+pad)+1 : tileSize*(j+pad+1) , tileSize*(i+pad)+1 : tileSize*(i+pad+1)) = webread(url);
    end
end

imshow(rescale(imgArray))

end