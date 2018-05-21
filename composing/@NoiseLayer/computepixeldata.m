function pixelData = computepixeldata(obj)
%COMPUTEPIXELDATA Summary of this function goes here
%   Detailed explanation goes here

% Store current random seed.
previousRandomSeed = rng;

% Apply new randomSeed.
rng(obj.randomSeed);

% Noise size
noiseSize = round(obj.size ./ obj.scale);

switch obj.type
    case 'uniform'
        pixelData = randd([-1 1],noiseSize);
    case 'gaussian'
        pixelData = randn(noiseSize);
    case 'fbm'
        pixelData = createfbmnoise(noiseSize);
    case 'simplex'
        pixelData = createsimplexnoise(obj.size,obj.scale);
end

% Apply scale.
pixelData = imresize(pixelData,obj.size);

% Restore random seed.
rng(previousRandomSeed);
end

