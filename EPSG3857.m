function [tileX, tileY] = EPSG3857(latitude, longitude, zoom)
%Convert EPSG3857 Projection coordinates into tile coordinates
%
%   EXAMPLES:
%       University of Iowa Pentacrest
%       [tileX,tileY]  = EPSG3857(41.661, -91.536, 15)
%
%   INPUT:
%       latitude - the latitude of the desired location 
%           (-90,90) in degrees
%       longitude - the longitude of the desired location
%           [-180,180] in degrees
%       zoom - the level of zoom
%           [0,infinity)
%
%   OUTPUT:
%       tileX - the # x tile
%       tileY - the # y tile
%

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

%determine total dimensions in tiles
tileNum = 2^zoom;

sinLatitude = sin(latitude * pi/180);

%determine pixel x/y location
pixelX = ((longitude + 180) / 360) * tileNum;
pixelY = (0.5 - log((1 + sinLatitude) / (1 - sinLatitude)) / (4 * pi)) * tileNum;

%determine tile # as pixel # / size of tile
tileX = floor(pixelX);
tileY = floor(pixelY);

end

