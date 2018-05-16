function obj = applyperiodicboundaries(obj,spaceBoundingBox)
%APPLYPERIODICBOUNDARIES Summary of this function goes here
%   Detailed explanation goes here

% Validate input.
validateattributes( ...
    spaceBoundingBox, ...
    {'BoundingBox'}, ...
    {'nonsparse','nonempty','scalar'});

% Detect if obj is completely out of the spaceBoundingBox in one
% dimension.
centroidDistanceVector = obj.boundingBox.centroid-spaceBoundingBox.centroid;
isOutsideBoundingBox = ...
    abs(centroidDistanceVector) > ...
    (obj.boundingBox.dimensions+spaceBoundingBox.dimensions)/2;

% Apply the periodic boundaries, where necessary.
translationVector = -isOutsideBoundingBox.*spaceBoundingBox.dimensions.*sign(centroidDistanceVector);
obj.translate(translationVector);
end

