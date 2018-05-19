function noise = createsimplexnoise(size,scale)
%CREATESIMPLEXNOISE Summary of this function goes here
%   Detailed explanation goes here

% Validate input.
validateattributes( ...
    size, ...
    {'numeric'}, ...
    {'real','finite','nonnan','nonsparse','nonempty','positive','integer','vector','numel',2});

validateattributes( ...
    scale, ...
    {'numeric'}, ...
    {'real','finite','nonnan','nonsparse','nonempty','positive','vector','numel',2});

speedUpFactor = 5;

if min(scale)<speedUpFactor
    warning( ...
        'Simplex noises with scales<%d may take long to compute.', ...
        speedUpFactor)
    
    speedUpFactor = min(scale);
end

randomOffset = rand*10000;

height = size(1);
width = size(2);

noiseWidth = round(width/speedUpFactor);
noiseHeight = round(height/speedUpFactor);

noise = zeros(noiseHeight,noiseWidth);

scale = scale/speedUpFactor;

for y = 1:noiseHeight
    for x = 1:noiseWidth        
        noise(y,x) = calculatesimplexpoint2d( ...
            (y/scale(2)+randomOffset), ...
            (x/scale(1)+randomOffset));
    end
end

% Scale noise.
noise = imresize(noise,size);

% Normalize noise.
noise = mat2gray(noise)-0.5;
end



