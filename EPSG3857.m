function [tileX, tileY] = EPSG3857(latitude, longitude, zoom, tileSize)

sinLatitude = sin(latitude * pi/180);

pixelX = ((longitude + 180) / 360) * tileSize * 2^zoom;

pixelY = (0.5 - log((1 + sinLatitude) / (1 - sinLatitude)) / (4 * pi)) * tileSize * 2^zoom;

numberOfTilesWide = 2^zoom;

numberOfTilesHigh = numberOfTilesWide;

tileX = floor(pixelX / tileSize);

tileY = floor(pixelY / tileSize);

end

