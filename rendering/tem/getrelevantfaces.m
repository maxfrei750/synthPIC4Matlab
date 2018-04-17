function relevantFaceIndices = getrelevantfaces(vertices,faces,rayIncidentPoints_x,rayIncidentPoints_y)
%GETRELEVANTFACES Determines faces which are relevant for the raytracing.

%% Tranform project vertices on the z-plane.
vertices2D = vertices(:,1:2);

%% Create triangulationObject
triangulationObject = triangulation(faces,vertices2D);

%% Determine triangles hit by rays.
relevantFaceIndices = pointLocation(triangulationObject,rayIncidentPoints_x,rayIncidentPoints_y);
% Remove NaNs
relevantFaceIndices(isnan(relevantFaceIndices)) = [];
% Only keep unique triangleIndices.
relevantFaceIndices = unique(relevantFaceIndices);
end

