function scale = pixelScale(latitude, zoom, tileSize)
%Determine the pixel resolution of a given map
%measured in meters/pixel
%
%   EXAMPLES:
%       scale = pixelScale(41.661, 15, 512)
%
%   INPUT:
%       latitude - the latitude of the desired location
%           (-90,90) in degrees
%       zoom - the zoom level of the tile
%           [0,infinity)
%       tileSize - the resolution of the tile in pixels
%           probably either 256 or 512

%https://wiki.openstreetmap.org/wiki/Zoom_levels


if latitude < -90 || 90 < latitude
    error('latitude must be between [-90,90] degrees');
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

earthCirc = 2*pi * 6378137;

scale = earthCirc * cos(deg2rad(latitude)) / 2^(zoom+8) / (tileSize/256);

end

