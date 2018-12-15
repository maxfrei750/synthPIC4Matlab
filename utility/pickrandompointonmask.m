function [x,y] = pickrandompointonmask(mask)
%PICKRANDOMPOINTONMASK Summary of this function goes here
%   Detailed explanation goes here

assert(any(mask(:)),'Cannot pick a point, because mask is completely false.');

% Get number of pixels of the mask.
nPixels = numel(mask);

% Create linear mask indices.
maskIndices = 1:nPixels;

% Select only the linear indices of true pixels.
maskIndices_true = maskIndices(mask(:));

% Get the number of true pixels.
nMaskIndices_true = numel(maskIndices_true);

% Pick a random linear index of a true pixel.
randomIndex_true = randi(nMaskIndices_true);

% Get the linear index of the random pixel in the mask.
randomIndex = maskIndices_true(randomIndex_true);

% Convert the linear index into the associated x- and y-coordinates.
[y,x] = ind2sub(size(mask),randomIndex);
end

