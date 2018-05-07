function [relevantFaceIndices,relevantRayIndices] = getrelevantfacesandrays(vertices,faces,rayIncidentPoints_x,rayIncidentPoints_y)
%GETRELEVANTFACES Determines faces which are relevant for the raytracing.

%% Get number of faces.
nFaces = size(faces,1); 

%% Tranform project vertices on the z-plane.
vertices2D = vertices(:,1:2);

%% Create triangulationObject
triangulationObject = triangulation(faces,vertices2D);

%% Determine triangles hit by rays.
relevantFaceIndices_hit = pointLocation(triangulationObject,rayIncidentPoints_x,rayIncidentPoints_y);

%% Determine relevant rays.
nRays = size(rayIncidentPoints_x,1);

isRelevantRay = ~isnan(relevantFaceIndices_hit);
relevantRayIndices = 1:nRays;
relevantRayIndices = relevantRayIndices(isRelevantRay);

%% Determine triangles with a point inside the tile.
% Remove NaNs
relevantFaceIndices_hit(isnan(relevantFaceIndices_hit)) = [];

safetyTileOverlapFactor = 0.1; % number of tiles to overlap in each direction

x_min = min(rayIncidentPoints_x);
x_max = max(rayIncidentPoints_x);
x_delta = x_max-x_min;

y_min = min(rayIncidentPoints_y);
y_max = max(rayIncidentPoints_y);
y_delta = y_max-y_min;

% Apply safety overlap.
x_min = x_min-safetyTileOverlapFactor*x_delta;
x_max = x_max+safetyTileOverlapFactor*x_delta;

y_min = y_min-safetyTileOverlapFactor*y_delta;
y_max = y_max+safetyTileOverlapFactor*y_delta;

P1 = vertices2D(faces(:,1),:);
P2 = vertices2D(faces(:,2),:);
P3 = vertices2D(faces(:,3),:);

isRelevantFace_insideTile = ...
     ((P1(:,1) >= x_min) & (P1(:,1) <= x_max) & (P1(:,2) >= y_min) & (P1(:,2) <= y_max)) | ...
     ((P2(:,1) >= x_min) & (P2(:,1) <= x_max) & (P2(:,2) >= y_min) & (P2(:,2) <= y_max)) | ...
     ((P3(:,1) >= x_min) & (P3(:,1) <= x_max) & (P3(:,2) >= y_min) & (P3(:,2) <= y_max));
 
 relevantFaceIndices_insideTile = 1:nFaces;
 
 relevantFaceIndices_insideTile = ...
     relevantFaceIndices_insideTile(isRelevantFace_insideTile)';
 
%% Only keep unique triangleIndices.
relevantFaceIndices = unique([relevantFaceIndices_hit;relevantFaceIndices_insideTile]);
%relevantFaceIndices = relevantFaceIndices_insideTile;
 
end

