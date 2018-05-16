clear
close all

sphere = Geometry('sphere',50);
sphere.position = [50 50 0];

mesh = sphere.mesh;

% Extract vertices, faces from mesh.
vertices = mesh.vertices;
faces = mesh.faces;

vertices = single(vertices);
faces = single(faces);

% Reshape data to fit the needs of the rayTriGPU-function.
P0 = vertices(faces(:,1),:);
P1 = vertices(faces(:,2),:);
P2 = vertices(faces(:,3),:);

rayOrigin = single([50 50 10e3]);


x_min = 0;
x_max = 100;

y_min = 0;
y_max = 100;

% Calculate the coordinates of the pixels of the virtual imaging screen.
x_steps = linspace( ...
    floor(x_min)+0.5, ...
    ceil(x_max)-0.5, ...
    ceil((ceil(x_max)-floor(x_min))));

y_steps = linspace( ...
    floor(y_min)+0.5, ...
    ceil(y_max)-0.5, ...
    ceil((ceil(y_max)-floor(y_min))));

% Determine number of pixels.
nPixels_x = numel(x_steps);
nPixels_y = numel(y_steps);

nPixels = nPixels_x*nPixels_y;

% Generate one ray for each pixel.
nRays = nPixels;

% Make a list of all the pixel coordinates.
[pixelCentroids_x,pixelCentroids_y]  = meshgrid(x_steps,y_steps);

pixelCentroids_x = pixelCentroids_x(:);
pixelCentroids_y = pixelCentroids_y(:);
pixelCentroids_z = zeros(nPixels,1);

pixelCentroids = ...
    horzcat(pixelCentroids_x,pixelCentroids_y,pixelCentroids_z);

% Calculate the ray directions and push them to the GPU.
rayDirections_in = normalizeVector3d(pixelCentroids-rayOrigin);
rayDirections_in = gpuArray(single(rayDirections_in));

% Calculate the intersection distances of each incident ray.
[intersectionDistancesArray, ...
    intersectionFlagsArray] = arrayfun(...
    @rayTriGPU, ...
    P0(:,1)', P0(:,2)', P0(:,3)', ...
    P1(:,1)', P1(:,2)', P1(:,3)', ...
    P2(:,1)', P2(:,2)', P2(:,3)', ...
    rayOrigin(:,1), rayOrigin(:,2), rayOrigin(:,3), ...
    rayDirections_in(:,1),rayDirections_in(:,2),rayDirections_in(:,3)); %#ok<*PFBNS>

t = max(