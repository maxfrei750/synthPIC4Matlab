% clear
% close all

%% Inputs:
imageWidth = 300;
imageHeight = 300;

tileSize = 100;

% % Create a mesh.
% dodecahedron = Geometry('dodecahedron',100);
% dodecahedron.subdivisionLevel = 5;
% dodecahedron.smoothingLevel = 2;
% dodecahedron.rotationAxisDirection = [1 1 1];
% dodecahedron.rotationAngleDegree = 30;
% dodecahedron.position = [300 400 100];
% 
% mesh = dodecahedron.mesh;

%% Parameters
detectorPosition = [-1000 -500 3000];

%% Rendering
% Extract vertices and faces from mesh.
vertices = mesh.vertices;
faces = mesh.faces;

% Split vertice coordinates.
vertices_x = vertices(:,1);
vertices_y = vertices(:,2);
vertices_z = vertices(:,3);

% Reshape data to fit the needs of the rayTriGPU-function.
P0 = vertices(faces(:,1),:);
P1 = vertices(faces(:,2),:);
P2 = vertices(faces(:,3),:);

% Add two triangles for the background.
P0(end+1,:) = [0 0 0];
P1(end+1,:) = [0 imageHeight 0];
P2(end+1,:) = [imageWidth imageHeight 0];

P0(end+1,:) = [0 0 0];
P1(end+1,:) = [imageWidth 0 0];
P2(end+1,:) = [imageWidth imageHeight 0];

% Set the ray origin to the center of the bounding box in x- and y- and to
% quasi-infinity in z- direction.
rayOrigin = [imageWidth/2 imageHeight/2 10e9];

% Calculate tiles
nTiles_x = ceil(imageWidth/tileSize);
nTiles_y = ceil(imageHeight/tileSize);

nTiles = nTiles_x*nTiles_y;

thicknessMapTiles = cell(nTiles_x,nTiles_y);
tic;
parfor iTile = 1:nTiles
    
    iTile_x = mod(iTile-1,nTiles_x)+1;
    iTile_y = floor((iTile-1)/nTiles_x)+1;
    
    x_min = (iTile_x-1)*tileSize;
    x_max = x_min+tileSize;
    
    x_max = clip(x_max,0,imageWidth);
    
    y_min = (iTile_y-1)*tileSize;
    y_max = y_min+tileSize;
    
    y_max = clip(y_max,0,imageHeight);
    
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
    pixelCentroids_z = zeros(nPixels,1);
    
    pixelCentroids = ...
        horzcat(pixelCentroids_x,pixelCentroids_y,pixelCentroids_z);
    
    % Calculate the ray directions and push them to the GPU.
    rayDirections_in = normalizeVector3d(pixelCentroids-rayOrigin);
    rayDirections_in = gpuArray(rayDirections_in);
    
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
    thicknessMapTile = reshape(transmissionDistances,nPixels_y,nPixels_x);
    
    % Save tile.
    thicknessMapTiles{iTile} = gather(thicknessMapTile);
end
toc;

%% Stitch tiles together.

thicknessMap = zeros(imageHeight,imageWidth);

for iTile_x = 1:nTiles_x
    
    x_min = (iTile_x-1)*tileSize+1;
    x_max = x_min+tileSize-1;
    
    x_max = clip(x_max,1,imageWidth);
    
    for iTile_y = 1:nTiles_y
               
        y_min = (iTile_y-1)*tileSize+1;
        y_max = y_min+tileSize-1;
        
        y_max = clip(y_max,1,imageHeight);
        
        thicknessMap(y_min:y_max,x_min:x_max) = ...
            thicknessMapTiles{iTile_x,iTile_y};
        
    end
end

transmissionCoefficient = 0.005;
% Calculate the relative transmission intensity.
% Source: Hornbogen, Skrotzki: Mikro- und Nanoskopie der Werkstoffe
intensityMap = exp(-transmissionCoefficient*thicknessMap);

imshow(intensityMap);
