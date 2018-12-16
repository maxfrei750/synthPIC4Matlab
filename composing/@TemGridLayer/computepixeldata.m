function pixelData = computepixeldata(obj)
%COMPUTEPIXELDATA Summary of this function goes here
%   Detailed explanation goes here

% Store current random seed.
previousRandomSeed = rng;

% Apply new randomSeed.
rng(obj.randomSeed);

% Image size
imageWidth = obj.size(2);
imageHeight = obj.size(1);

% Noise size
noiseSize = round(obj.size ./ obj.scale);

noiseWidth = noiseSize(2);
noiseHeight = noiseSize(1);

% Create a regular grid of seeds.
seedImage = zeros(imageHeight,imageWidth);

nTilesY = obj.nTiles(1);
nTilesX = obj.nTiles(2);

nTiles = nTilesY*nTilesX;

tileHeight =  imageHeight/nTilesY;
tileWidth = imageWidth/nTilesX;

[x,y] = meshgrid(0.5:1:nTilesX-0.5,0.5:1:nTilesY-0.5);

x = round(x*tileWidth);
y = round(y*tileHeight);

% Offset the seeds to get an unregular hole pattern.
maximumRelativeOffset = 1-obj.regularity;

x = x(:)+randi(round(maximumRelativeOffset*[-tileWidth tileWidth]),nTiles,1);
y = y(:)+randi(round(maximumRelativeOffset*[-tileHeight tileHeight]),nTiles,1);

x = clip(x,1,imageWidth);
y = clip(y,1,imageHeight);

% Plant seeds.
for i = 1:nTiles
    seedImage(y(i),x(i)) = 1;
end

% Calculate a distance map as height map.
distanceMap = bwdist(seedImage,'euclidean');

% Fill the sinks in the height map to get the holes.
mask = imbinarize(...
    mat2gray(distanceMap),...
    'adaptive',...
    'ForegroundPolarity','dark',...
    'Sensitivity',obj.relativeHoleSize);

pixelData = imgaussfilt(mat2gray(distanceMap),20).*mask;

% Crop out a random piece of the pixeldata, that has the desired size.
x_min = randi(imageWidth-noiseWidth+1);
y_min = randi(imageHeight-noiseHeight+1);

pixelData = imcrop(pixelData,[x_min y_min noiseWidth noiseHeight]);

% Smooth the image to get smooth edges after the image resize.
pixelData = imgaussfilt(pixelData,3);

% Invert image.
pixelData = imcomplement(pixelData);

% Normalize pixelData.
pixelData = mat2gray(pixelData);

% Apply scale.
pixelData = imresize(pixelData,obj.size);

% Restore random seed.
rng(previousRandomSeed);
end

