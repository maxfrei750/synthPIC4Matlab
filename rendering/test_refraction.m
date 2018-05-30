clear
close all

rng(2)

height = 100;
width = 100;

% Set indices of refraction.
ior_inside = 1;
ior_outside = 1.3;

% Create mesh
d_g = 50;
s_g = 1.2;

nPrimaryParticles = 3;

agglomerationMode = 'BCCA';

diameterDistribution = makedist( ...
    'lognormal', ...
    'mu',log(d_g), ...
    'sigma',log(s_g));

fraction = Fraction('octahedron',diameterDistribution);

% fraction.subdivisionLevel = 1;
% 
% fraction.displacementLayers = Displacement('simplex'); % Simplex noise is continuous
% fraction.displacementLayers.strength = 1;
% fraction.displacementLayers.scale = 20;

agglomerate = Agglomerate(agglomerationMode,fraction,nPrimaryParticles);

mesh = agglomerate.completeMesh;

% Position mesh.
mesh = mesh.centerat([width/2 height/2 0]);

% Extract vertices, faces from mesh.
vertices = mesh.vertices;
faces = mesh.faces;

% Set up rendering grid.
xSteps = 0.5:width-0.5;
ySteps = 0.5:height-0.5;

nRays = numel(xSteps)*numel(ySteps);

% Set initialRayDirection.
initialRayDirection = [0 0 -1];

% Initialize Maps.
exitDirections = zeros(nRays,3);
exitPositions = zeros(nRays,3);

iRay = 0;

for x = xSteps
    for y = ySteps
        iRay = iRay+1;
        
        rayDirection = initialRayDirection; % Parallel light.
        rayOrigin = [x y 10e5];
                
        % Pick a random raycolor for visualization.
        rayColor = rand(3,1);
        
        while true
            [isIntersecting,distances] = ...
                ray_mesh_intersect(rayOrigin,rayDirection,vertices,faces);
            
            % Stop loop as soon as there are no intersections for this ray.
            if ~any(isIntersecting)
                break
            end
            
            relevantDistances = distances(isIntersecting);
            
            % Ignore non-positive distances, because the ray may only move
            % forward.
            relevantDistances(relevantDistances<=0) = inf;
            
            % Only the first intersection is relevant.
            minimumDistance = min(relevantDistances);
            relevantFaceIndex = find(distances == minimumDistance);
            
            if minimumDistance == inf
                break
            end
            
            % If there are multiple equidistant faces, then randomly pick
            % one of them.
            nRelevantFaces = numel(relevantFaceIndex);
            if nRelevantFaces>1
                iRelevantFace = randi(nRelevantFaces);
                relevantFaceIndex = relevantFaceIndex(iRelevantFace);
                clear iRelevantFace
            end
                
            relevantFace = faces(relevantFaceIndex,:);
            relevantVertices = vertices(relevantFace,:);
            
            % Calculate intersectionVertex.
            intersectionVertex = rayOrigin+rayDirection*minimumDistance;
            
%             % Visualization -----------------------------
% %             texture = ones(mesh.nFaces,3);
% %             texture(relevantFaceIndex,:) = [1 0 0];
% %             mesh.texture = texture;
% 
%             hPatch = mesh.draw;
%             hPatch.FaceAlpha = 0;
%             
%             hPoint = scatter3(intersectionVertex(1),intersectionVertex(2),intersectionVertex(3));
%             hPoint.MarkerEdgeColor = rayColor;
%             
%             hRay = plot3([rayOrigin(1) intersectionVertex(1)],[rayOrigin(2) intersectionVertex(2)],[rayOrigin(3) intersectionVertex(3)]);
%             hRay.Color = rayColor;
%             hRay.LineWidth = 0.5;
%             
%             xlim([0 100]);
%             ylim([0 100]);
%             zlim([-50 50]);
%             drawnow
            % -------------------------------------------
            
            %% Calculate new direction of the refracted ray based on Snell's law.            
            % Incident ray.
            incidentRay = intersectionVertex-rayOrigin;
            
            % If resulting ray is extremely short, then treat ray as
            % terminated.
            if all(abs(incidentRay)<eps)
                break
            end
            
            % Calculate faceNormal of the intersected face.
            normalVector = meshFaceNormals(relevantVertices,[1 2 3]);
            
            % Calculate new direction of the refracted/reflected ray.
            rayDirection = calculatenewraydirection(incidentRay,normalVector,ior_inside,ior_outside);
            
            %% Use intersectionpoint as new ray origin.
            rayOrigin = intersectionVertex;
            
            a=1;
            
        end
        
        exitDirections(iRay,:) = rayDirection;
        exitPositions(iRay,:) = rayOrigin;
          
    end
end

exitAngles_degree = acosd(dot(exitDirections,repmat(initialRayDirection,nRays,1),2));

minimumExitAngleMap_degree = ones(height,width)*180;

for x = 0:width-1
    j = x+1;
    
    isRelevantExitPositionX = exitPositions(:,1) >= x & exitPositions(:,1) <= x+1;
    
    for y = 0:height-1
        i = y+1;
        
        isRelevantExitPositionY = exitPositions(:,2) >= y & exitPositions(:,2) <= y+1;
        
        isRelevantExitPosition = isRelevantExitPositionX & isRelevantExitPositionY;
        
        relevantExitAngles = exitAngles_degree(isRelevantExitPosition);
        
        if ~isempty(relevantExitAngles)
            minimumExitAngleMap_degree(i,j) = min(relevantExitAngles);
        end
    end
end

minimumExitAngleMap_degree = real(minimumExitAngleMap_degree);

angleThreshold_degree = 10;

intensityMap = minimumExitAngleMap_degree<=angleThreshold_degree;

imshow(intensityMap)


