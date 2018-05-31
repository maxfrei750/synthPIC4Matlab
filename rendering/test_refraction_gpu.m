clear
close all

doVisualize = false;

height = 200;
width = 200;

% Set indices of refraction.
ior_inside = 1.3;
ior_outside = 1;

%% Create geometry.
rng(1)

geometry = Geometry('octahedron',70);
geometry.rotationAngleDegree = rand*360;
geometry.rotationAxisDirection = rand(1,3);

% geometry.subdivisionLevel = 2;
% geometry.smoothingLevel = 2;
% 
% displacement = Displacement('simplex');
% displacement.scale = 10;
% displacement.strength = 2;
% geometry.displacementLayers = displacement;

mesh = geometry.mesh;
mesh = mesh.centerat([width/2 height/2 0]);

% Extract vertices, faces from mesh.
vertices = mesh.vertices;
faces = mesh.faces;

nFaces = mesh.nFaces;

% Reshape data to fit the needs of the rayTriGPU-function.
P0 = vertices(faces(:,1),:);
P1 = vertices(faces(:,2),:);
P2 = vertices(faces(:,3),:);

%% Create rays.

nSteps_x = width;
nSteps_y = height;

steps_x = linspace( ...
    0.5, ...
    width-0.5, ...
    nSteps_x);

steps_y = linspace( ...
    0.5, ...
    height-0.5, ...
    nSteps_y);

[xGrid,yGrid] = meshgrid(steps_x,steps_y);

nRays = numel(xGrid);

% For visualization: create a color for each ray.
rayColors = parula(nRays);
randomColorOrder = randperm(nRays);
rayColors = rayColors(randomColorOrder,:);
%

rayOrigins = [xGrid(:) yGrid(:) ones(nRays,1)*1e2];
rayOrigins = gpuArray(rayOrigins);

initialRayDirections = gpuArray(repmat([0 0 -1],nRays,1));

rayDirections = initialRayDirections;
isRelevantRay = true(nRays,1);

distancesDummy = NaN(nRays,nFaces,'gpuArray');
isIntersectingDummy = false(nRays,nFaces,'gpuArray');

% Calculate facenormals of the geometry for later use.
faceNormals = meshFaceNormals(vertices,faces);

tic;

iRaytracingStep = 0;

% Keep on raytraying as long as there are relevant, i.e. unfinished rays.
while true
    iRaytracingStep = iRaytracingStep+1;
    
    distances = distancesDummy;
    isIntersecting = isIntersectingDummy;
    
    % Perform raytracing.
    [distances(isRelevantRay,:),isIntersecting(isRelevantRay,:)] = arrayfun(...
        @rayTriGPU, ...
        P0(:,1)', P0(:,2)', P0(:,3)', ...
        P1(:,1)', P1(:,2)', P1(:,3)', ...
        P2(:,1)', P2(:,2)', P2(:,3)', ...
        rayOrigins(isRelevantRay,1), rayOrigins(isRelevantRay,2), rayOrigins(isRelevantRay,3), ...
        rayDirections(isRelevantRay,1),rayDirections(isRelevantRay,2),rayDirections(isRelevantRay,3)); %#ok<*PFBNS>
    
    % Only exit angles of rays, which hit the object at least once have to
    % be considered later on, during the creation of the exitAngleMap.
    if iRaytracingStep == 1
        isRelevantExitRay = any(isIntersecting,2);
        nRelevantExitRays = sum(isRelevantExitRay);
    end
        
    % Stop loop as soon as there are no intersections for this ray.
    if ~any(isIntersecting(:))
        break
    end
    
    % Remove very msll and negative distances.
    distances(distances<=1e-10) = inf;
    
    % Determine relevant rays.
    isRelevantRay = any(distances<inf,2);
    
    % Get minimum intersection distances and associated faces.
    [minimumDistances,relevantFaceIndices] = min(distances,[],2);
    
    % Extract relevant data.
    relevantRayOrigins = rayOrigins(isRelevantRay,:);
    relevantRayDirections = rayDirections(isRelevantRay,:);
    minimumDistances = minimumDistances(isRelevantRay);
    relevantFaceIndices = relevantFaceIndices(isRelevantRay);
    
    % Stop the raytracing, if 99% of the relevant rays were traced.
    nActiveRays = numel(minimumDistances);
    
    if nActiveRays/nRelevantExitRays < 0.1
        break
    end
    
    % Calculate intersection points.
    intersectionPoints = relevantRayOrigins+relevantRayDirections.*minimumDistances;
    
    %% Calculate new direction of the refracted ray based on Snell's law.
    % Construct incident ray.
    incidentRays = intersectionPoints-relevantRayOrigins;
    
    % Get relevant faceNormals.
    relevantFaceNormals = faceNormals(relevantFaceIndices,:);
    
    % Calculate new direction of the refracted/reflected ray.
    rayDirections(isRelevantRay,:) = calculatenewraydirection(incidentRays,relevantFaceNormals,ior_outside,ior_inside);
    
    
    
    %     sum(isRelevantRay(:))
    %     exitAngles_degree = acosd(dot(rayDirections,initialRayDirections,2));
    %     exitAngleMap_degree = reshape(exitAngles_degree,height,width);
    %     imagesc(exitAngleMap_degree)
    % %     colorbar
    %     drawnow
    
    % Visualization
    if doVisualize
        nRelevantRays = sum(isRelevantRay);
        
        hPatch = mesh.draw;
        hPatch.FaceAlpha = 0;
        
        hPoint = scatter3(intersectionPoints(:,1),intersectionPoints(:,2),intersectionPoints(:,3));
        %     hPoint.CData = rayColors(isRelevantRay,:);
        %     colormap(jet)
        hRay = plot3( ...
            [rayOrigins(isRelevantRay,1) intersectionPoints(:,1)]', ...
            [rayOrigins(isRelevantRay,2) intersectionPoints(:,2)]', ...
            [rayOrigins(isRelevantRay,3) intersectionPoints(:,3)]');
        drawnow
    end
    
    %% Use intersectionpoint as new ray origin.
    rayOrigins(isRelevantRay,:) = intersectionPoints;
end

toc;

if doVisualize
hPatch = mesh.draw;
hPatch.FaceAlpha = 0;
hOut = drawVector3d(rayOrigins,rayDirections*100,'ShowArrowHead','off');
end

exitPositions = rayOrigins;
exitAngles_degree = acosd(dot(rayDirections,initialRayDirections,2));
minimumExitAngleMap_degree = ones(height,width)*180;

tic;
% Create exitAngleMap
exitPixelIndices_x = round(exitPositions(:,1));
exitPixelIndices_y = round(exitPositions(:,2));

% Exlude rays with exitPositions outside of the image.
isOutside_x = exitPixelIndices_x < 1 | exitPixelIndices_x > width;
isOutside_y = exitPixelIndices_y < 1 | exitPixelIndices_y > height;
isRelevantExitRay = isRelevantExitRay & ~isOutside_x & ~isOutside_y;

nRelevantExitRays = sum(isRelevantExitRay);
nRelevantExitRays = gather(nRelevantExitRays);

relevantExitRayIndices = 1:nRays;
relevantExitRayIndices = relevantExitRayIndices(isRelevantExitRay);

relevantExitPixelIndices_x = exitPixelIndices_x(isRelevantExitRay);
relevantExitPixelIndices_y = exitPixelIndices_y(isRelevantExitRay);

relevantExitPixelIndices_x = gather(relevantExitPixelIndices_x);
relevantExitPixelIndices_y = gather(relevantExitPixelIndices_y);

relevantExitAngles_degree = exitAngles_degree(isRelevantExitRay);
relevantExitAngles_degree = gather(relevantExitAngles_degree);

minimumExitAngleMap_degree = zeros(height,width);
minimumExitAngleMap_degree(isRelevantExitRay) = 180;

for i = 1:nRelevantExitRays
    currentAngle = minimumExitAngleMap_degree(relevantExitPixelIndices_y(i),relevantExitPixelIndices_x(i));
    newAngle = relevantExitAngles_degree(i);
    
    if isnan(currentAngle) || newAngle<currentAngle
        minimumExitAngleMap_degree(relevantExitPixelIndices_y(i),relevantExitPixelIndices_x(i)) = newAngle;
    end
end

toc;

%%

filter = ones(3)/9;
minimumExitAngleMap_degree = uint8(conv2(minimumExitAngleMap_degree, filter, 'same'));

figure
imagesc(minimumExitAngleMap_degree)

angleThreshold_degree = 90;

intensityMap = minimumExitAngleMap_degree<=angleThreshold_degree;

% mesh.draw

figure
imshow(intensityMap)
