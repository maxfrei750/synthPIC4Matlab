function subMasks = getsubmasks(obj)
%GETSUBMASKS Summary of this function goes here
%   Detailed explanation goes here

subMasks = cell(obj.nObjects,1);

for iSubMesh = 1:obj.nObjects
    % Extract submesh.
    subMesh = obj.extractsubmesh(iSubMesh);
    
    % Get mask of the subMesh.
    subMasks{iSubMesh} = subMesh.mask;
end

end

