function coverage = calculateimagecoverage(mesh,surfaceMask)
%CALCULATEIMAGECOVERAGE Summary of this function goes here
%   Detailed explanation goes here

surfaceMask = logical(surfaceMask);
isCoverablePixel = surfaceMask(:);

% Get number of coverable pixels.
nCoverablePixels = sum(isCoverablePixel);

% Get image size.
[imageHeight,imageWidth] = size(surfaceMask);

% Extract vertices and faces from the mesh.
vertices = mesh.vertices;
faces = mesh.faces;

% Tranform project vertices on the z-plane.
vertices2D = vertices(:,1:2);

% Create triangulationObject
triangulationObject = triangulation(faces,vertices2D);

% Create x and y coordinates of the pixel centroids.
[x,y] = meshgrid((1:imageWidth)-0.5,(1:imageHeight)-0.5);

% Determine number of covered pixels.
iFaces_hit = pointLocation(triangulationObject,x(:),y(:));
isCoveredPixel = ~isnan(iFaces_hit);
% isCoveredPixel = reshape(isCoveredPixel,imageHeight,imageWidth);

% Get number of covered, coverable pixels.
isCoveredAndCoverablePixel = isCoveredPixel & isCoverablePixel;
nCoveredAndCoverablePixels = sum(isCoveredAndCoverablePixel);

% Calculate coverage.
coverage = nCoveredAndCoverablePixels/nCoverablePixels;
end

