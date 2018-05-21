function transmissionLengthMap = rendertransmissionlengthmap(obj)
%RENDERTRANSMISSIONLENGTHMAP Generates a transmissionmap of the provided geometry.

% If map was already rendered, then return the already rendered map.
if ~isempty(obj.transmissionLengthMap)
    transmissionLengthMap = obj.transmissionLengthMap;
    return
end

% Check if a suitable gpu is available.
assert(isgpuavailable,'This function needs a suitable GPU to run.');

% Extract variables from object.
height = obj.imageSize(1);
width = obj.imageSize(2);
tileSize = obj.tileSize;
relativeResolution = obj.relativeResolution;
mesh = obj.mesh;

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
        
        transmissionLengthMapTiles = cell(nTiles_x,nTiles_y);
        
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
            
            % Determine relevant faces and rays.
            [relevantFaceIndices,relevantRayIndices] = getrelevantfacesandrays( ...
                vertices,faces, ...
                pixelCentroids_x,pixelCentroids_y);

            nRelevantFaces = numel(relevantFaceIndices);
            nRelevantRays = numel(relevantRayIndices);
            
            % If there are no relevant rays or faces, then set the
            % transmission distances of all pixels of the current tile to
            % zero and continue
            if nRelevantRays == 0 || nRelevantFaces == 0
                transmissionLengthMapTiles{iTile} = ...
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
            
            % Calculate transmissionLengthArray
            transmissionLengths = calculatetransmissionlengths( ...
                intersectionDistancesArray, ...
                intersectionFlagsArray, ...
                mesh.facesObjectIDs(relevantFaceIndices));
            
            % Reshape the data to get a thickness map.
            transmissionLengthMapTile = reshape(transmissionLengths,nPixels_y,nPixels_x);
            
            % Save tile.
            transmissionLengthMapTiles{iTile} = transmissionLengthMapTile;
        end
        
        doRetry = false;
        
    catch matlabError
        
        % If a memory related error was thrown, issue a warning, decrease
        % the tileSize and retry the rendering.
        switch matlabError.identifier
            case {'parallel:gpu:array:OOM','parallel:gpu:array:pmaxsize'}
                tileSize = round(tileSize/2);
                warning([ ...
                    'Out of memory. Trying to re-render with a ' ...
                    'temporary ''tileSize'' of %d. To prevent future' ...
                    ' re-renders, decrease ''tileSize'' permanently.'] ...
                    ,tileSize);
            otherwise %If another error was thrown, rethrow it.
                rethrow(matlabError)
        end
        
    end
end

%% Stitch tiles together.

transmissionLengthMapSlices = cell(1,nTiles_y);

for iSlice = 1:nTiles_y
    transmissionLengthMapSlices{iSlice} = ...
        [transmissionLengthMapTiles{:,iSlice}];
end

transmissionLengthMap = vertcat(transmissionLengthMapSlices{:});

% Resize image, in case that relativeResolution<1.
transmissionLengthMap = imresize(transmissionLengthMap,[height width]);

% Push data to the gpu again.
transmissionLengthMap = gpuArray(transmissionLengthMap);

%% Assign the associated ...Map-attribute of the object.
obj.transmissionLengthMap = transmissionLengthMap;
end

