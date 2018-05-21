function shadowMap = rendershadowmap(mesh,width,height,varargin)
%RENDERSHADOWMAP Generates a shadowmap of the provided geometry.
%   Needs a GPU to be run.
%   
%   Inputs:
%   =======
%
%   mesh - Mesh-object with at least the fields 'vertices' and 'faces'.
%
%   width - Width of the rendered shadowmap.
%
%   height - Height of the rendered shadowmap.
%
%   
%   Optional name-value-pairs:
%   ==========================
%
%   'tileSize' - Sidelength of the square tiles, which are rendered.
%                Affects the memory consumption and the render speed.
%                Default: 100
%
%   'relativeResolution' - Sets the rendering resolution.
%                          Example: for 'relativeResolution', 0.5 only 
%                          every second pixel of the shadowmap is
%                          calculated and the remaining pixels are
%                          interpolatet.
%                          Default: 0.5
%
%   'detectorPosition' - Position of the detector in space. Affects
%                        position of the shadows.
%                        Default: [-1000 -500 3000]
%                        
%
%   'transmissionCoefficient' - Transmissioncoefficient of the material.
%                               Default: 0.005
%

%% Parse and validate inputs.

% Validation functions.

isValidMesh = @(x) validateattributes( ...
    x, ...
    {'Mesh'}, ...
    {'numel',1});

isValidScalarPixelInput = @(x) validateattributes( ...
    x, ...
    {'numeric'}, ...
    {'real','finite','nonnan','nonsparse','nonempty','positive','scalar','integer'});

isValidDetectorPosition = @(x) validateattributes( ...
    x, ...
    {'numeric'}, ...
    {'real','finite','nonnan','nonsparse','nonempty','row','numel',3});

isValidTransmissionCoefficient = @(x) validateattributes( ...
    x, ...
    {'numeric'}, ...
    {'real','finite','nonnan','nonsparse','nonempty','positive','scalar'});

isValidRelativeResolution = @(x) validateattributes( ...
    x, ...
    {'numeric'}, ...
    {'real','finite','nonnan','nonsparse','nonempty','scalar','>=',0,'<=',1});

% Default values
defaultDetectorPosition = [-1000 -500 3000];
defaultTileSize = 100;
defaultTransmissionCoefficient = 0.005;
defaultRelativeResolution = 0.5;

% Setup input parser

p = inputParser;

p.addRequired('mesh',isValidMesh);
p.addRequired('width',isValidScalarPixelInput);
p.addRequired('height',isValidScalarPixelInput);
p.addParameter('tileSize',defaultTileSize,isValidScalarPixelInput);
p.addParameter('detectorPosition',defaultDetectorPosition,isValidDetectorPosition);
p.addParameter('transmissionCoefficient',defaultTransmissionCoefficient,isValidTransmissionCoefficient);
p.addParameter('relativeResolution',defaultRelativeResolution,isValidRelativeResolution);

p.parse(mesh,width,height,varargin{:});

tileSize = p.Results.tileSize;
detectorPosition = p.Results.detectorPosition;
transmissionCoefficient = p.Results.transmissionCoefficient;
relativeResolution = p.Results.relativeResolution;

%% Rendering
% Extract vertices and faces from mesh.
vertices = mesh.vertices;
faces = mesh.faces;

% Reshape data to fit the needs of the rayTriGPU-function.
P0 = vertices(faces(:,1),:);
P1 = vertices(faces(:,2),:);
P2 = vertices(faces(:,3),:);

% Set the ray origin to the center of the bounding box in x- and y- and to
% quasi-infinity in z- direction.
rayOrigin = [width/2 height/2 10e9];

% Calculate tiles
nTiles_x = ceil(width/tileSize);
nTiles_y = ceil(height/tileSize);

nTiles = nTiles_x*nTiles_y;

transmissionDistanceMapTiles = cell(nTiles_x,nTiles_y);

parfor iTile = 1:nTiles
    
    % Calculate current tile indices in x- andy y- direction.
    iTile_x = mod(iTile-1,nTiles_x)+1;
    iTile_y = floor((iTile-1)/nTiles_x)+1;
    
    % Calculate boundaries of the current tile.
    x_min = (iTile_x-1)*tileSize;
    x_max = x_min+tileSize;
    
    x_max = clip(x_max,0,width);
    
    y_min = (iTile_y-1)*tileSize;
    y_max = y_min+tileSize;
    
    y_max = clip(y_max,0,height);
    
    % Calculate the coordinates of the pixels of the virtual imaging screen.
    x_steps = linspace( ...
        floor(x_min)+0.5, ...
        ceil(x_max)-0.5, ...
        ceil((ceil(x_max)-floor(x_min))*relativeResolution));
    
    y_steps = linspace( ...
        floor(y_min)+0.5, ...
        ceil(y_max)-0.5, ...
        ceil((ceil(y_max)-floor(y_min))*relativeResolution));
    
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
        rayDirections_in(:,1),rayDirections_in(:,2),rayDirections_in(:,3)); %#ok<*PFBNS>
    
    % Only keep first intersection points.
    distances_in = min(distances_in,[],2);
    
    % Calculate ray incident points.
    rayIncidentPoints = rayOrigin+rayDirections_in.*distances_in;
    
    % Free memory on GPU.
    [~] = gather(distances_in);
    
    % Calculate direction of outgoing rays.
    rayDirections_out = ...
        normalizeVector3d(rayIncidentPoints-detectorPosition);
    
    rayDirections_out = gpuArray(rayDirections_out);
    
    % Calculate the intersection distances of each outgoing ray.
    [distances_out, ~] = arrayfun(...
        @rayTriGPU, ...
        P0(:,1)', P0(:,2)', P0(:,3)', ...
        P1(:,1)', P1(:,2)', P1(:,3)', ...
        P2(:,1)', P2(:,2)', P2(:,3)', ...
        detectorPosition(:,1), ...
        detectorPosition(:,2), ...
        detectorPosition(:,3), ...
        rayDirections_out(:,1), ...
        rayDirections_out(:,2), ...
        rayDirections_out(:,3));
    
    % Set distances bigger than the maximum possible distance to NaN.
    distances_out_max = sqrt(sum((rayIncidentPoints-detectorPosition).^2,2))+1;
    distances_out(distances_out>distances_out_max) = NaN;
    
    % Calculate the transmission distances for each ray by computing the
    % difference of the intersection distances of the outgoing rays.
    transmissionDistances = max(distances_out,[],2)-min(distances_out,[],2);
    
    % Free memory on GPU.
    [~] = gather(distances_out);
    
    % NaNs represent no intersections, so set the thickness to 0.
    transmissionDistances(isnan(transmissionDistances)) = 0;
    
    % Reshape the data to get a thickness map.
    transmissionDistanceMapTile = reshape(transmissionDistances,nPixels_y,nPixels_x);
    
    % Save tile.
    transmissionDistanceMapTiles{iTile} = ...
        gather(transmissionDistanceMapTile);
end

%% Stitch tiles together.

transmissionDistanceMapSlices = cell(1,nTiles_y);

for iSlice = 1:nTiles_y
    transmissionDistanceMapSlices{iSlice} = ...
        [transmissionDistanceMapTiles{:,iSlice}];
end

transmissionDistanceMap = vertcat(transmissionDistanceMapSlices{:});

% Calculate the relative transmission intensity.
% Source: Hornbogen, Skrotzki: Mikro- und Nanoskopie der Werkstoffe
shadowMap = exp(-transmissionCoefficient*transmissionDistanceMap);

lateralDetectorAngle = atand(-detectorPosition(2)/detectorPosition(1));

% shadowMap = imcomplement(imdilate(imcomplement(shadowMap),strel('line',3,lateralDetectorAngle)));
% 
% shadowMap = imgaussfilt(shadowMap,1);

shadowMap = imresize(shadowMap,[height width]);



end
