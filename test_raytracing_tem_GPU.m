clear
close all


% Create a mesh.
position = [0 0 0];
scale = 100;

[vertices,faces] = createIcosphere;
vertices = vertices*scale+position;

load('example_dodecahedron.mat')

tic;

% Split vertice coordinates.
vertices_x = vertices(:,1);
vertices_y = vertices(:,2);
vertices_z = vertices(:,3);

% Determin borders of the bounding box.
x_min = min(vertices_x);
x_max = max(vertices_x);

y_min = min(vertices_y);
y_max = max(vertices_y);

z_min = min(vertices_z);
z_max = max(vertices_z);

% Set the ray origin to the center of the bounding box in x- and y- and to
% quasi-infinity in z- direction.
rayOrigin = [mean([x_min x_max]) mean([y_min y_max]) z_max*1000]; 

% Calculate the coordinates of the pixels of the virtual imaging screen.
x_steps = linspace(floor(x_min)+0.5,ceil(x_max)-0.5,ceil(x_max)-floor(x_min));
y_steps = linspace(floor(y_min)+0.5,ceil(y_max)-0.5,ceil(y_max)-floor(y_min));

% Determine number of pixels.
nPixels_x = numel(x_steps);
nPixels_y = numel(y_steps);

nPixels = nPixels_x*nPixels_y;

% Make a list of all the pixel coordinates.
[pixelCentroids_x,pixelCentroids_y]  = meshgrid(x_steps,y_steps);

pixelCentroids_x = pixelCentroids_x(:);
pixelCentroids_y = pixelCentroids_y(:);
pixelCentroids_z = repmat(z_min,nPixels,1);

pixelCentroids = ...
    horzcat(pixelCentroids_x,pixelCentroids_y,pixelCentroids_z);

% Free some memory.
clear pixelCentroids_x pixelCentroids_y pixelCentroids_z

% Calculate the ray directions and push them to the GPU.
rayDirections = normalizeVector3d(pixelCentroids-rayOrigin);
rayDirections = gpuArray(rayDirections);

% Reshape data to fit the needs of the rayTriGPU-function.
P0 = vertices(faces(:,1),:);
P1 = vertices(faces(:,2),:);
P2 = vertices(faces(:,3),:);

% Calculate the intersection distances of each ray.
[distanceArray, ~] = arrayfun(@rayTriGPU, P0(:,1)', P0(:,2)', P0(:,3)', ...
                            P1(:,1)', P1(:,2)', P1(:,3)', ...
                            P2(:,1)', P2(:,2)', P2(:,3)', ...
                            rayOrigin(:,1), rayOrigin(:,2), rayOrigin(:,3), ...
                            rayDirections(:,1),rayDirections(:,2),rayDirections(:,3));

% Calculate the transmission length for each ray by computing the
% difference of the intersection distances.
thicknessArray = max(distanceArray,[],2)-min(distanceArray,[],2);

% NaNs represent no intersections, so set the thickness to 0.
thicknessArray(isnan(thicknessArray)) = 0;

% Reshape the data to get a thickness map.
thicknessArray = reshape(thicknessArray,nPixels_y,nPixels_x);

transmissionCoefficient = 0.005;
% Calculate the relative transmission intensity.
% Source: Hornbogen, Skrotzki: Mikro- und Nanoskopie der Werkstoffe
intensityMap = exp(-transmissionCoefficient*thicknessArray);
toc;
imshow(intensityMap);