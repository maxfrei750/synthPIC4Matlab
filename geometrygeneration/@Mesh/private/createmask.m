function mask = createmask(mesh)
%CREATEMASK Creates a binary mask of the object.

% Get 2d boundingbox of the mesh.
boundingBox2d = mesh.boundingBox2d;

x_min = floor(boundingBox2d(1));
y_min = floor(boundingBox2d(2)); 

x_max = ceil(boundingBox2d(1)+boundingBox2d(3));
y_max = ceil(boundingBox2d(2)+boundingBox2d(4));

width = x_max-x_min;
height = y_max-y_min;

% Create a grid of pixel centroids.
steps_x = linspace( ...
    x_min+0.5, ...
    x_max-0.5, ...
    width);

steps_y = linspace( ...
    y_min, ...
    y_max-0.5, ...
    height);

[xGrid,yGrid] = meshgrid(steps_x,steps_y);

% Transform project vertices on the z-plane.
vertices2D = mesh.vertices(:,1:2);

% Create triangulationObject
triangulationObject = triangulation(mesh.faces,vertices2D);

% Determine triangles hit by rays.
hitFaceIndices = pointLocation(triangulationObject,xGrid(:),yGrid(:));

% Create mask.
mask = ~isnan(hitFaceIndices);
mask = reshape(mask,height,width);
end

