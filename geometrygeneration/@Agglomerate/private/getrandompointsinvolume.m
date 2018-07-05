function [randomPoints,weights] = getrandompointsinvolume(obj)
%GETRANDOMPOINTSINVOLUME Summary of this function goes here
%   Detailed explanation goes here

% Determine total volume of the object and the volumes of the primary 
% particles.
meshes = [obj.mesh obj.getalldescendants.mesh];
volumes = arrayfun(@(x) x.volume,meshes);
volume_total = sum(volumes);

% Draw one random point per 2x2x2 volume.
nRandomPoints_total = round(volume_total/8);

relativeVolumes = volumes/volume_total;

nRandomPointsArray = round(relativeVolumes*nRandomPoints_total);

% Initialization.
randomPoints = zeros(nRandomPoints_total,3);
weights = zeros(nRandomPoints_total,1);

startIndex = 1;

% Iterate object and all descendants.
objectList = [obj obj.getalldescendants];
nObjects = numel(objectList);

for iObject = 1:nObjects
    object = objectList(iObject);
    
    nRandomPoints = nRandomPointsArray(iObject);
    
    endIndex  = startIndex+nRandomPoints-1;
    
    randomPoints(startIndex:endIndex,:) = ...
        getrandompointsinmesh(object.mesh,nRandomPoints);
    
    weights(startIndex:endIndex) = object.bulkDensity;
    
    startIndex = endIndex+1;
end
end

