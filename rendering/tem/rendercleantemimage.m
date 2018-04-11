function cleanTemImage = rendercleantemimage(mesh,width,height,varargin)
%RENDERCLEANTEMIMAGE Generates a clean TEM image of the provided geometry.
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
%                Default: 500
%
%   'relativeResolution' - Sets the rendering resolution.
%                          Example: for 'relativeResolution', 0.5 only
%                          every second pixel of the shadowmap is
%                          calculated and the remaining pixels are
%                          interpolatet.
%                          Default: 1
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

isValidTransmissionCoefficient = @(x) validateattributes( ...
    x, ...
    {'numeric'}, ...
    {'real','finite','nonnan','nonsparse','nonempty','positive','scalar'});

isValidRelativeResolution = @(x) validateattributes( ...
    x, ...
    {'numeric'}, ...
    {'real','finite','nonnan','nonsparse','nonempty','scalar','>=',0,'<=',1});

% Default values
defaultTileSize = 500;
defaultTransmissionCoefficient = 0.005;
defaultRelativeResolution = 1;

% Setup input parser

p = inputParser;

p.addRequired('mesh',isValidMesh);
p.addRequired('width',isValidScalarPixelInput);
p.addRequired('height',isValidScalarPixelInput);
p.addParameter('tileSize',defaultTileSize,isValidScalarPixelInput);
p.addParameter('transmissionCoefficient',defaultTransmissionCoefficient,isValidTransmissionCoefficient);
p.addParameter('relativeResolution',defaultRelativeResolution,isValidRelativeResolution);

p.parse(mesh,width,height,varargin{:});

tileSize = p.Results.tileSize;
transmissionCoefficient = p.Results.transmissionCoefficient;
relativeResolution = p.Results.relativeResolution;

%% Rendering
% Extract vertices, faces from mesh.
vertices = mesh.vertices;
faces = mesh.faces;

% Reshape data to fit the needs of the rayTriGPU-function.
P0 = vertices(faces(:,1),:);
P1 = vertices(faces(:,2),:);
P2 = vertices(faces(:,3),:);

% Set the ray origin to the center of the bounding box in x- and y- and to
% quasi-infinity in z- direction.
rayOrigin = [width/2 height/2 10e9];

% Try to render with the current tileSize. If it fails, decrease it and try
% again.

doRetry = true;

while doRetry
    
    try
        % Calculate tiles
        nTiles_x = ceil(width/tileSize);
        nTiles_y = ceil(height/tileSize);
        
        nTiles = nTiles_x*nTiles_y;
        
        transmissionDistanceMapTiles = cell(nTiles_x,nTiles_y);
        
        % Render on multiple GPUs if available.
        for iTile = 1:nTiles
            
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
            [intersectionDistancesArray, intersectionFlagsArray] = arrayfun(...
                @rayTriGPU, ...
                P0(:,1)', P0(:,2)', P0(:,3)', ...
                P1(:,1)', P1(:,2)', P1(:,3)', ...
                P2(:,1)', P2(:,2)', P2(:,3)', ...
                rayOrigin(:,1), rayOrigin(:,2), rayOrigin(:,3), ...
                rayDirections_in(:,1),rayDirections_in(:,2),rayDirections_in(:,3)); %#ok<*PFBNS>
            
            %             % Restructure intersectionDistances and intersectionFlags into cell arrays.
            %             intersectionDistances = mat2cell(intersectionDistances,ones(nPixels,1));
            %             intersectionFlags = mat2cell(intersectionFlags,ones(nPixels,1));
            
            totalTransmissionDistances = zeros(nPixels,1,'gpuArray');
            
            for iRay = 1:nPixels
                % Select intersectionFlags of current ray.
                intersectionFlags = intersectionFlagsArray(iRay,:);
                
                % If no intersections occured, then continue.
                if ~any(intersectionFlags)
                    continue
                end
                
                % Select intersectionDistances of current ray.
                intersectionDistances = intersectionDistancesArray(iRay,:);
                
                % Keep only relevant distances.
                intersectionDistances = intersectionDistances(intersectionFlags);
                
                % Get relevant facesObjectIDs.
                facesObjectIDs = mesh.facesObjectIDs(intersectionFlags);
                
                % Order distances and facesObjectIDs according to distances.
                [intersectionDistances,orderIndices] = sort(intersectionDistances);
                facesObjectIDs = facesObjectIDs(orderIndices);
                
                nRelevantFaceObjectIDs = size(facesObjectIDs,1);
                
                index = (1:nRelevantFaceObjectIDs)';
                isEven = @(x) ~mod(x,2);
                
                doKeep = ...
                    index == 1 | ...    % first element
                    index == nRelevantFaceObjectIDs & isEven(index) | ...  % last element, if its index is even
                    index == nRelevantFaceObjectIDs-1 & isEven(index) | ...  % last but one element, if its index is even
                    facesObjectIDs(index) == [facesObjectIDs(index(1:end-1)+1);NaN] & ~isEven(index) | ...
                    facesObjectIDs(index) == [NaN;facesObjectIDs(index(2:end)-1)] & isEven(index);
                
                intersectionDistances = intersectionDistances(doKeep);
                
                transmissionDistances = intersectionDistances-[0 intersectionDistances(1:end-1)];
                transmissionDistances = transmissionDistances(2:2:end);
                
                totalTransmissionDistances(iRay) = sum(transmissionDistances);
            end
            %             %% for testing -------------------------------------
            %             linearIdx = 80*nPixels_y+45;
            %             testFlags = gather(intersectionFlags(linearIdx,:));
            %             testDistances = gather(intersectionDistances(linearIdx,:));
            %
            %             % Keep only relevant distances.
            %             testDistances = testDistances(testFlags);
            %
            %             % Keep only relevant facesObjectIDs.
            %             facesObjectIDs = facesObjectIDs(testFlags);
            %
            %             % Order distances and objectIDs according to distances.
            %             [testDistances,orderIdx] = sort(testDistances);
            %             facesObjectIDs = facesObjectIDs(orderIdx);
            %
            %             nRelevantFaceObjectIDs = size(facesObjectIDs,1);
            %
            %             index = (1:nRelevantFaceObjectIDs)';
            %             isEven = @(x) ~mod(x,2);
            %
            %
            %             doKeep = ...
            %                 index == 1 | ...    % first element
            %                 index == nRelevantFaceObjectIDs & isEven(index) | ...  % last element, if its index is even
            %                 index == nRelevantFaceObjectIDs-1 & isEven(index) | ...  % last but one element, if its index is even
            %                 facesObjectIDs(index) == [facesObjectIDs(index(1:end-1)+1);NaN] & ~isEven(index) | ...
            %                 facesObjectIDs(index) == [NaN;facesObjectIDs(index(2:end)-1)] & isEven(index);
            %
            %             testDistances = testDistances(doKeep);
            %
            %             transmissionDistances = testDistances-[0 testDistances(1:end-1)];
            %             transmissionDistances = transmissionDistances(2:2:end);
            %             %% -------------------------------------------------
            
            % Free memory on GPU.
            [~] = gather(intersectionDistances);
            
            % Reshape the data to get a thickness map.
            transmissionDistanceMapTile = reshape(totalTransmissionDistances,nPixels_y,nPixels_x);
            
            % Save tile.
            transmissionDistanceMapTiles{iTile} = ...
                gather(transmissionDistanceMapTile);
        end
        
        doRetry = false;
        
    catch matlabError
        
        % If a memory related error was thrown, issue a warning, decrease
        % the tileSize and retry the rendering.
        switch matlabError.identifier
            case {'parallel:gpu:array:OOM','parallel:gpu:array:pmaxsize'}
                tileSize = round(tileSize/2);
                warning('Out of memory. Trying to rerender with a ''tileSize'' of %d.',tileSize);
            otherwise %If another error was thrown, rethrow it.
                rethrow(matlabError)
        end
        
    end
end

%% Stitch tiles together.

transmissionDistanceMapSlices = cell(1,nTiles_y);

for iSlice = 1:nTiles_y
    transmissionDistanceMapSlices{iSlice} = ...
        [transmissionDistanceMapTiles{:,iSlice}];
end

transmissionDistanceMap = vertcat(transmissionDistanceMapSlices{:});

%% Calculate transmission intensities of each pixel.
% Calculate the relative transmission intensity.
% Source: Hornbogen, Skrotzki: Mikro- und Nanoskopie der Werkstoffe
cleanTemImage = exp(-transmissionCoefficient*transmissionDistanceMap);

% Resize image, in case that relativeResolution<1.
cleanTemImage = imresize(cleanTemImage,[height width]);
end

