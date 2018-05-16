clear
close all

% Calculate detector position.
%detectorPosition = [x_max y_max z_max].*[-100 -50 100];

detectorPosition = [-1000 -500 3000];

% Create a mesh.
position = [100 100 0];
scale = 100;

[vertices,faces] = createIcosphere;
vertices = vertices*scale+position;
%load('example_dodecahedron.mat');
%load('example_sphere.mat');

% Split vertice coordinates.
vertices_x = vertices(:,1);
vertices_y = vertices(:,2);
vertices_z = vertices(:,3);

% Determin borders of the bounding box.

% x_min = min(vertices_x)*2;
% x_max = max(vertices_x)*2;
% 
% y_min = min(vertices_y)*2;
% y_max = max(vertices_y)*2;

x_min = 0;
x_max = 300;

y_min = 0;
y_max = 300;

z_min = min(vertices_z);
z_max = max(vertices_z);

% Set the ray origin to the center of the bounding box in x- and y- and to
% quasi-infinity in z- direction.
rayOrigin = [mean([x_min x_max]) mean([y_min y_max]) 10e9];

% Calculate the coordinates of the pixels of the virtual imaging screen.
x_steps = linspace(floor(x_min)+0.5,ceil(x_max)-0.5,(ceil(x_max)-floor(x_min)));
y_steps = linspace(floor(y_min)+0.5,ceil(y_max)-0.5,(ceil(y_max)-floor(y_min)));

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
rayDirections_in = normalizeVector3d(pixelCentroids-rayOrigin);
rayDirections_in = gpuArray(rayDirections_in);

% Reshape data to fit the needs of the rayTriGPU-function.
P0 = vertices(faces(:,1),:);
P1 = vertices(faces(:,2),:);
P2 = vertices(faces(:,3),:);

% Add two triangles for the background.
P0(end+1,:) = [x_min y_min z_min];
P1(end+1,:) = [x_min y_max z_min];
P2(end+1,:) = [x_max y_max z_min];

P0(end+1,:) = [x_min y_min z_min];
P1(end+1,:) = [x_max y_min z_min];
P2(end+1,:) = [x_max y_max z_min];

% Calculate the intersection distances of each incident ray.
[distances_in, ~] = arrayfun(...
    @rayTriGPU, ...
    P0(:,1)', P0(:,2)', P0(:,3)', ...
    P1(:,1)', P1(:,2)', P1(:,3)', ...
    P2(:,1)', P2(:,2)', P2(:,3)', ...
    rayOrigin(:,1), rayOrigin(:,2), rayOrigin(:,3), ...
    rayDirections_in(:,1),rayDirections_in(:,2),rayDirections_in(:,3));

% Only keep first intersection points.
distances_in = min(distances_in,[],2);

% Calculate ray incident points.
rayIncidentPoints = rayOrigin+rayDirections_in.*distances_in;

% Free memory on GPU.
distances_in = gather(distances_in);

% Calculate direction of outgoing rays.
rayDirections_out = normalizeVector3d(rayIncidentPoints-detectorPosition);
rayDirections_out = gpuArray(rayDirections_out);

% Calculate the intersection distances of each outgoing ray.
[distances_out, ~] = arrayfun(...
    @rayTriGPU, ...
    P0(:,1)', P0(:,2)', P0(:,3)', ...
    P1(:,1)', P1(:,2)', P1(:,3)', ...
    P2(:,1)', P2(:,2)', P2(:,3)', ...
    detectorPosition(:,1),detectorPosition(:,2),detectorPosition(:,3), ...
    rayDirections_out(:,1),rayDirections_out(:,2),rayDirections_out(:,3));



% Set distances bigger than the maximum possible distance to NaN.
distances_out_max = sqrt(sum((rayIncidentPoints-detectorPosition).^2,2))+1;
nFaces = size(faces,1);
distances_out(distances_out>distances_out_max) = NaN;

% Calculate the transmission distances for each ray by computing the
% difference of the intersection distances of the outgoing rays.
transmissionDistances = max(distances_out,[],2)-min(distances_out,[],2);

% Free memory on GPU.
distances_out = gather(distances_out);

% NaNs represent no intersections, so set the thickness to 0.
transmissionDistances(isnan(transmissionDistances)) = 0;

% Reshape the data to get a thickness map.
thicknessMap = reshape(transmissionDistances,nPixels_y,nPixels_x);

transmissionCoefficient = 0.005;
% Calculate the relative transmission intensity.
% Source: Hornbogen, Skrotzki: Mikro- und Nanoskopie der Werkstoffe
intensityMap = exp(-transmissionCoefficient*thicknessMap);

% Scale image up
imshow(intensityMap);

% Plot incident points.
% figure
% scatter3(rayIncidentPoints(:,1),rayIncidentPoints(:,2),rayIncidentPoints(:,3));
% hold on
% 
% % Plot ray origin.
% scatter3(rayOrigin(1),rayOrigin(2),rayOrigin(3));
% text(rayOrigin(1),rayOrigin(2),rayOrigin(3),'Ray Origin');
% 
% % Plot incident rays.
% rayVectors_in = rayDirections_in.*distances_in;
% % quiver3( ...
% %     repmat(rayOrigin(1),nPixels,1), ...
% %     repmat(rayOrigin(2),nPixels,1), ...
% %     repmat(rayOrigin(3),nPixels,1), ...
% %     rayVectors_in(:,1), ...
% %     rayVectors_in(:,2), ...
% %     rayVectors_in(:,3), ...
% %     1);
% 
% Plot detector position
%scatter3(detectorPosition(1),detectorPosition(2),detectorPosition(3));
%text(detectorPosition(1),detectorPosition(2),detectorPosition(3),'Detector');

% % Plot outgoing rays.
% distances_out = min(distances_out,[],2);
% rayVectors_out = -rayDirections_out.*distances_out;
% quiver3( ...
%     rayIncidentPoints(:,1), ...
%     rayIncidentPoints(:,2), ...
%     rayIncidentPoints(:,3), ...
%     rayVectors_out(:,1), ...
%     rayVectors_out(:,2), ...
%     rayVectors_out(:,3), ...
%     1);
