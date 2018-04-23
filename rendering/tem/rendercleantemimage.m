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
%                Default: 512
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
% Get binaryObjectMask.
[~,binaryObjectMask] = renderobjectmask(mesh,width,height);
binaryObjectMask = gather(binaryObjectMask);

% Extract vertices, faces from mesh.
vertices = mesh.vertices;
faces = mesh.faces;

% Reshape data to fit the needs of the rayTriGPU-function.
P0 = vertices(faces(:,1),:);
P1 = vertices(faces(:,2),:);
P2 = vertices(faces(:,3),:);

% Calculate number of faces.
nFaces = size(faces,1);

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
            
            % Select tile of the binaryObjectMask.
            binaryObjectMaskTile = ...
                im2single(binaryObjectMask(y_min+1:y_max,x_min+1:x_max));
            
            % Resize binaryObjectMaskTile to match relativeResolution.
            if relativeResolution ~= 1
                binaryObjectMaskTile = ...
                    imresize(binaryObjectMaskTile,relativeResolution,'nearest');
                binaryObjectMaskTile = logical(binaryObjectMaskTile);
                
                % Dilate binaryObjectMaskTile to ensure that object edges are
                % covered sufficiently.
                binaryObjectMaskTile = imdilate(binaryObjectMaskTile,strel('disk',1));
            end
            
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
            rayDirections_in = gpuArray(rayDirections_in);
            
            % Determine relevant faces.
%             relevantFaceIndices = getrelevantfaces(vertices,faces,pixelCentroids_x,pixelCentroids_y);
            relevantFaceIndices = 1:nFaces;
            
            nRelevantFaces = numel(relevantFaceIndices);
            
            % Determine relevant rays.
            isRelevantRay = binaryObjectMaskTile(:);
            relevantRayIndices = gpuArray(1:nRays);
            relevantRayIndices = relevantRayIndices(isRelevantRay);
            nRelevantRays = numel(relevantRayIndices);
            
            % If there are no relevant rays or faces, then set the
            % transmission distances of all pixels of the current tile to
            % zero and continue
            if nRelevantRays == 0 || nRelevantFaces == 0
                transmissionDistanceMapTiles{iTile} = ...
                    zeros(nPixels_y,nPixels_x);
                
                continue
            end
            
            % Initialize intersectionDistancesArray and
            % intersectionFlagsArray.            
            intersectionDistancesArray = NaN(nRays,nRelevantFaces,'gpuArray');
            intersectionFlagsArray = false(nRays,nRelevantFaces,'gpuArray');
            
            % Calculate the intersection distances of each incident ray.
            [intersectionDistancesArray(relevantRayIndices,:), ...
                intersectionFlagsArray(relevantRayIndices,:)] = arrayfun(...
                @rayTriGPU, ...
                P0(relevantFaceIndices,1)', P0(relevantFaceIndices,2)', P0(relevantFaceIndices,3)', ...
                P1(relevantFaceIndices,1)', P1(relevantFaceIndices,2)', P1(relevantFaceIndices,3)', ...
                P2(relevantFaceIndices,1)', P2(relevantFaceIndices,2)', P2(relevantFaceIndices,3)', ...
                rayOrigin(:,1), rayOrigin(:,2), rayOrigin(:,3), ...
                rayDirections_in(relevantRayIndices,1),rayDirections_in(relevantRayIndices,2),rayDirections_in(relevantRayIndices,3)); %#ok<*PFBNS>
                        
            %% Initialization
            % Transpose ray tracing outputs.
            intersectionDistancesArray = intersectionDistancesArray';
            intersectionFlagsArray  = intersectionFlagsArray';
                        
            %% Group rays. 
            % Maybe don't use indices, but logical indexing?
            
            rayIndices = 1:nRays;
            nHitsArray = sum(intersectionFlagsArray,1);
            
            % 0 hit rays
            isHitRay_0 = nHitsArray == 0;
            rayIndices_0Hits = rayIndices(isHitRay_0);
            
            % uneven hit rays
            isHitRay_unevenNumberOfHits = ~isEven(nHitsArray);
            rayIndices_unevenNumberOfHits = ...
                rayIndices(isHitRay_unevenNumberOfHits);

            % 2 hit rays
            isHitRay_2 = nHitsArray == 2;
            rayIndices_2Hits = rayIndices(isHitRay_2);
            
            % 4+ even hit rays
            isHitRay_even4plus = nHitsArray >= 4 & isEven(nHitsArray);
            rayIndices_4HitsPlus = rayIndices(isHitRay_even4plus);
            
            %% Initialize transmissionDistanceMapTile.
            transmissionDistances = zeros(nRays,1,'gpuArray');
            
            %% Treat 0 hit rays.
            % Could be ommited, because transmissionDistances was
            % initialized with 0. However, this is more robust.
            transmissionDistances(rayIndices_0Hits) = 0;
            
            %% Treat rays with an uneven number of hits.
            % Rays with an uneven number of hits are assumed to never leave
            % some geometry, because there is no outgoing intersection.
            % Therefore, the transmission distance is infinite.
            transmissionDistances(rayIndices_unevenNumberOfHits) = inf;
            
            %% Treat 2 hit rays.
            % For rays with just 2 hits, the transmssion distance can be
            % calculated based on the minimum and maximum transmission
            % distance.
            transmissionDistances(rayIndices_2Hits) = ...
                max(intersectionDistancesArray(:,rayIndices_2Hits)) - ...
                min(intersectionDistancesArray(:,rayIndices_2Hits));
                
            %% Treat even 4+ hit rays.   
            
            for iRay = rayIndices_4HitsPlus
                % Select data of current ray.  
                intersectionDistances = intersectionDistancesArray(:,iRay);
                intersectionFlags = intersectionFlagsArray(:,iRay); 
                facesObjectIDs = mesh.facesObjectIDs;
                
                % Sort intersectionDistances, intersectionFlags and
                % facesObjectIDs according to intersectionDistances.
                [intersectionDistances,orderedIndices] = ...
                    sort(intersectionDistances);
                intersectionFlags = intersectionFlags(orderedIndices);
                facesObjectIDs = facesObjectIDs(orderedIndices);
                
                % Keep only facesObjectIDs of intersected faces.
                facesObjectIDs = facesObjectIDs(intersectionFlags);
                
                nIntersections = size(facesObjectIDs,1);
                alreadyEncounteredFacesObjectIDs = NaN(nIntersections,1);
                
                % skip first iteration
                isInsideObjectCounter = 1;
                alreadyEncounteredFacesObjectIDs(1) = facesObjectIDs(1);
                relevantIntersectionDistances = intersectionDistances(1);
                               
                for iIntersection = 2:nIntersections
                    facesObjectID = facesObjectIDs(iIntersection);
                    
                    wasIntersectedBefore = ...
                        facesObjectID == alreadyEncounteredFacesObjectIDs;
                                     
                    if any(wasIntersectedBefore)
                        % The ray is leaving an object.
                        isInsideObjectCounter = isInsideObjectCounter-1;
                        
                        % If the ray is outside all objects now, then add
                        % current intersectiondistance to the 
                        % relevantIntersectionDistances.
                        if isInsideObjectCounter == 0
                            relevantIntersectionDistances(end+1) = ...
                                intersectionDistances(iIntersection);
                        end
                        
                        % Remove the facesObjectID from the list of 
                        % alreadyEncounteredFacesObjectIDs, so that it will
                        % be processed again, if the object is concave and
                        % hit again by the current ray.
                        alreadyEncounteredFacesObjectIDs(wasIntersectedBefore) = NaN;
                        
                    else
                        % The ray is entering a new object.
                        isInsideObjectCounter = isInsideObjectCounter+1;
                        
                        % Add the object to the
                        % alreadyEncounteredFacesObjectIDs.
                        alreadyEncounteredFacesObjectIDs(iIntersection) = ...
                            facesObjectID;
                        
                        % If the ray is only inside a single object now, 
                        % then add the current intersectiondistance to the 
                        % relevantIntersectionDistances.
                        if isInsideObjectCounter == 1
                            relevantIntersectionDistances(end+1) = ...
                                intersectionDistances(iIntersection);
                        end
                    end
                end                       

                % Calculate the transmissionDistance of the current ray.
                objectTransmissionDistances = ...
                    relevantIntersectionDistances - ...
                    [0 relevantIntersectionDistances(1:end-1)];
                
                objectTransmissionDistances = ...
                    objectTransmissionDistances(2:2:end);
                
                transmissionDistances(iRay) = sum(objectTransmissionDistances);
            end
            
            % Reshape the data to get a thickness map.
            transmissionDistanceMapTile = reshape(transmissionDistances,nPixels_y,nPixels_x);
            
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
                warning('Out of memory. Trying to re-render with a ''tileSize'' of %d.',tileSize);
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

