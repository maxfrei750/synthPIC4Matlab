function refractionMap = renderrefractionmap(obj)
%RENDERREFRACTIONMAP renders a refractionMap.

% If map was already rendered, then return the already rendered map.
if ~isempty(obj.refractionMap)
    refractionMap = obj.refractionMap;
    return
end

% Check if a suitable gpu is available.
assert(isgpuavailable,'This function needs a suitable GPU to run.');

% Extract variables from object.
height = obj.imageSize(1);
width = obj.imageSize(2);
tileSize = obj.tileSize;
mesh = obj.mesh;

ior_inside = obj.ior_inside;
ior_outside = obj.ior_outside;

errorThreshold = 0.1;

% Extract vertices, faces from mesh.
vertices = mesh.vertices;
faces = mesh.faces;

nFaces = mesh.nFaces;

% Reshape data to fit the needs of the rayTriGPU-function.
P0 = vertices(faces(:,1),:);
P1 = vertices(faces(:,2),:);
P2 = vertices(faces(:,3),:);

%% Create rays.
steps_x = linspace( ...
    0.5, ...
    width-0.5, ...
    width);

steps_y = linspace( ...
    0.5, ...
    height-0.5, ...
    height);

[xGrid,yGrid] = meshgrid(steps_x,steps_y);

nRays_total = numel(xGrid);

rayOrigins = [xGrid(:) yGrid(:) ones(nRays_total,1)*1e2];

% Calculate facenormals of the geometry for later use.
faceNormals = meshFaceNormals(vertices,faces);

% Retrieve an binaryObjectMap to determine which rays need to be traced.
% binaryObjectMap = obj.renderbinaryobjectmap;
relevantRayIndices = getrelevantrays(vertices,faces,xGrid(:),yGrid(:));
binaryObjectMap = false(nRays_total,1);
binaryObjectMap(relevantRayIndices) = true;

% Try to render with the current tileSize. If it fails, decrease it and try
% again.

doRetry = true;

while doRetry
    
    try
        
        nRaysPerBatch = tileSize.^2;
        nBatches = ceil(nRays_total/nRaysPerBatch);
        
        isRelevantExitRay_total = true(nRays_total,1);
        nRelevantExitRays = 0;
        
        for iBatch = 1:nBatches
            
            % Calculate which rays belong to this batch.
            iRay_start = (iBatch-1)*nRaysPerBatch+1;
            iRay_end = iBatch*nRaysPerBatch;
            iRay_end = clip(iRay_end,1,nRays_total);
            
            nRays_batch = iRay_end-iRay_start+1;
            
            % Initialization of batch variables.
            rayOrigins_batch = gpuArray(rayOrigins(iRay_start:iRay_end,:));
            
            initialRayDirections_batch = gpuArray(repmat([0 0 -1],nRays_batch,1));
            rayDirections_batch = initialRayDirections_batch;
            isRelevantRay = binaryObjectMap(iRay_start:iRay_end);
            
            distancesDummy = NaN(nRays_batch,nFaces,'gpuArray');
            isIntersectingDummy = false(nRays_batch,nFaces,'gpuArray');
            
            isFirstRunOfBatch = true;
            
            % Keep on raytraying as long as no stop criterion is met.
            while true
                
                distances_batch = distancesDummy;
                isIntersecting = isIntersectingDummy;
                
                % Perform raytracing.
                [distances_batch(isRelevantRay,:), isIntersecting(isRelevantRay,:)] = arrayfun(...
                    @rayTriGPU, ...
                    P0(:,1)', P0(:,2)', P0(:,3)', ...
                    P1(:,1)', P1(:,2)', P1(:,3)', ...
                    P2(:,1)', P2(:,2)', P2(:,3)', ...
                    rayOrigins_batch(isRelevantRay,1), rayOrigins_batch(isRelevantRay,2), rayOrigins_batch(isRelevantRay,3), ...
                    rayDirections_batch(isRelevantRay,1),rayDirections_batch(isRelevantRay,2),rayDirections_batch(isRelevantRay,3)); %#ok<*PFBNS>
                
                % Only exit angles of rays, which hit the object at least once have to
                % be considered later on, during the creation of the exitAngleMap.
                if isFirstRunOfBatch
                    
                    % Save relevance of the exitrays of this batch.
                    isRelevantExitRay_batch = any(isIntersecting,2);
                    nRelevantExitRays_batch = sum(isRelevantExitRay_batch);
                    
                    % Save relevance of the exitrays of this batch.
                    isRelevantExitRay_total(iRay_start:iRay_end) = ...
                        gather(isRelevantExitRay_batch);
                    nRelevantExitRays = nRelevantExitRays+nRelevantExitRays_batch;
                    
                    % Set flag for first run to false.
                    isFirstRunOfBatch = false;
                end
                
                % Stop loop as soon as there are no intersections for this ray.
                if ~any(isRelevantExitRay_batch)
                    break
                end
                
                % Remove very small and negative distances.
                distances_batch(distances_batch<=1e-10) = inf;
                
                % Determine relevant rays.
                isRelevantRay = any(distances_batch<inf,2);
                
                % Get minimum intersection distances and associated faces.
                [minimumDistances,relevantFaceIndices] = min(distances_batch,[],2);
                
                % Extract relevant data.
                relevantRayOrigins = rayOrigins_batch(isRelevantRay,:);
                relevantRayDirections = rayDirections_batch(isRelevantRay,:);
                minimumDistances = minimumDistances(isRelevantRay);
                relevantFaceIndices = relevantFaceIndices(isRelevantRay);
                
                % Stop the raytracing, if the error threshold is reached.
                nActiveRays = numel(minimumDistances);
                
                if nActiveRays/nRelevantExitRays_batch <= errorThreshold
                    break
                end
                
                % Calculate intersection points.
                intersectionPoints = relevantRayOrigins+relevantRayDirections.*minimumDistances;
                
                %% Calculate new direction of the refracted ray based on Snell's law.
                % Construct incident ray.
                incidentRays = intersectionPoints-relevantRayOrigins;
                
                % Get relevant faceNormals.
                relevantFaceNormals = faceNormals(relevantFaceIndices,:);
                
                % Calculate new directions of the refracted/reflected rays.
                rayDirections_batch(isRelevantRay,:) = calculatenewraydirection(incidentRays,relevantFaceNormals,ior_outside,ior_inside);
                
                % Use intersectionpoints as new ray origins.
                rayOrigins_batch(isRelevantRay,:) = intersectionPoints;
            end
            
            exitPositions(iRay_start:iRay_end,:) = rayOrigins_batch;
            
            exitAngles_degree(iRay_start:iRay_end) = ...
                acosd(dot(rayDirections_batch,initialRayDirections_batch,2));
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

%% Create exitAngleMap
exitPixelIndices_x = round(exitPositions(:,1));
exitPixelIndices_y = round(exitPositions(:,2));

% Exlude rays with exitPositions outside of the image.
isOutside_x = exitPixelIndices_x < 1 | exitPixelIndices_x > width;
isOutside_y = exitPixelIndices_y < 1 | exitPixelIndices_y > height;
isRelevantExitRay_total = isRelevantExitRay_total & ~isOutside_x & ~isOutside_y;

nRelevantExitRays = sum(isRelevantExitRay_total);
nRelevantExitRays = gather(nRelevantExitRays);

relevantExitPixelIndices_x = exitPixelIndices_x(isRelevantExitRay_total);
relevantExitPixelIndices_y = exitPixelIndices_y(isRelevantExitRay_total);

relevantExitPixelIndices_x = gather(relevantExitPixelIndices_x);
relevantExitPixelIndices_y = gather(relevantExitPixelIndices_y);

relevantExitAngles_degree = exitAngles_degree(isRelevantExitRay_total);
relevantExitAngles_degree = gather(relevantExitAngles_degree);

minimumExitAngleMap_degree = zeros(height,width);
minimumExitAngleMap_degree(isRelevantExitRay_total) = 180;

for i = 1:nRelevantExitRays
    currentAngle = minimumExitAngleMap_degree(relevantExitPixelIndices_y(i),relevantExitPixelIndices_x(i));
    newAngle = relevantExitAngles_degree(i);
    
    if newAngle<currentAngle
        minimumExitAngleMap_degree(relevantExitPixelIndices_y(i),relevantExitPixelIndices_x(i)) = newAngle;
    end
end

%% Assign the associated ...Map-attribute of the object.
obj.refractionMap = refractionMap;
end

