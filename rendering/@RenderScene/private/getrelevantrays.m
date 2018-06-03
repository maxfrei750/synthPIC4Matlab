function relevantRayIndices = getrelevantrays(vertices,faces,rayIncidentPoints_x,rayIncidentPoints_y)
%GETRELEVANTRAYS Determines rays which are relevant for the raytracing.

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
end

