function [tileX, tileY] = EPSG3857(latitude, longitude, zoom, tileSize)
%Convert EPSG3857 Projection coordinates into tile coordinates
%
%   EXAMPLES:
%       University of Iowa Pentacrest
%       [tileX,tileY]  = EPSG3857(41.661, -91.536, 15, 256)
%
%   INPUT:
%       latitude - REQUIRED - the latitude of the desired location 
%           [-90,90] in degrees
%       longitude - REQUIRED - the longitude of the desired location
%           [-180,180] in degrees
%       zoom - REQUIRED - the level of zoom
%           [0,infinity)
%       tileSize - REQUIRED - the tile size, probably 256 or 512
%
%   OUTPUT:
%       tileX - the # x tile
%       tileY - the # y tile
%
% https://docs.microsoft.com/en-us/azure/azure-maps/zoom-levels-and-tile-grid?tabs=csharp

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

%determine total dimensions in tiles
tileNum = 2^zoom;

sinLatitude = sin(latitude * pi/180);

%determine pixel x/y location
pixelX = ((longitude + 180) / 360) * tileSize * tileNum;
pixelY = (0.5 - log((1 + sinLatitude) / (1 - sinLatitude)) / (4 * pi)) * tileSize * tileNum;

%determine tile # as pixel # / size of tile
tileX = floor(pixelX / tileSize);
tileY = floor(pixelY / tileSize);

end

