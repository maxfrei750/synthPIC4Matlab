function boundingBox2d = calculateboundingbox2d(mesh)
%CALCULATEBOUNDINGBOX2D Calculates the 2d boundingbox of a mesh in x and y.
%   The bounding box is specified as a 4-element position vector of the
%   form [xmin ymin width height].

% Get bounding box properties (only x and y).
boundingBoxDimensions = mesh.boundingBox.dimensions(1:2);
boundingBoxCentroid = mesh.boundingBox.centroid(1:2);

position = boundingBoxCentroid-boundingBoxDimensions/2;

boundingBox2d = [position boundingBoxDimensions];
end

