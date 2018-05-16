function [randomPoints,weights] = getrandompointsinvolume(obj)
%GETRANDOMPOINTSINVOLUME Summary of this function goes here
%   Detailed explanation goes here

% Determine total volume of the object and the volumes of the primary 
% particles.
volumes = [obj.childList.volume];
volume_total = sum(volumes);

% Draw one random point per 5x5x5 volume.
nRandomPoints_total = round(volume_total/125);

relativeVolumes = volumes/volume_total;

nRandomPointsArray = round(relativeVolumes*nRandomPoints_total);

% Initialization.
randomPoints = zeros(nRandomPoints_total,3);
weights = zeros(nRandomPoints_total,1);

startIndex = 1;

% Iterate all children.
for iChild = 1:obj.nChildren
    child = obj.childList(iChild);
    
    nRandomPoints = nRandomPointsArray(iChild);
    
    endIndex  = startIndex+nRandomPoints-1;
    
    randomPoints(startIndex:endIndex,:) = ...
        getrandompointsinmesh(child.mesh,nRandomPoints);
    
    weights(startIndex:endIndex) = child.bulkDensity;
    
    startIndex = endIndex+1;
end
end

