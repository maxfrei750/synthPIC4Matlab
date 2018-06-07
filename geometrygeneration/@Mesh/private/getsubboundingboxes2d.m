function subBoundingBoxes2d = getsubboundingboxes2d(obj)
%GETSUBBOUNDINGBOXES2D Summary of this function goes here
%   Detailed explanation goes here

subBoundingBoxes2d = zeros(obj.nObjects,4);

for iSubMesh = 1:obj.nObjects
    % Extract submesh.
    subMesh = obj.extractsubmesh(iSubMesh);
    
    % Get boundingBox of the subMesh.
    subBoundingBoxes2d(iSubMesh,:) = subMesh.boundingBox2d;
end

end

