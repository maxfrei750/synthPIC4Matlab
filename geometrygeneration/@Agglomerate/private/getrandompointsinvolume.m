function [randomPoints,weights] = getrandompointsinvolume(obj)
%GETRANDOMPOINTSINVOLUME Summary of this function goes here
%   Detailed explanation goes here

% Determine total volume of the object and the volumes of the primary 
% particles.
particles = obj.primaryParticles;
meshes = [particles.mesh];
volumes = [meshes.volume];
volume_total = sum(volumes);

% Draw one random point per 2x2x2 volume.
nRandomPoints_total = round(volume_total/8);

relativeVolumes = volumes/volume_total;

nRandomPointsArray = round(relativeVolumes*nRandomPoints_total);

% Initialization.
randomPoints = zeros(nRandomPoints_total,3);
weights = zeros(nRandomPoints_total,1);

startIndex = 1;

% Iterate primary particles.
for iParticle = 1:obj.nPrimaryParticles
    primaryParticle = particles(iParticle);
    
    nRandomPoints = nRandomPointsArray(iParticle);
    
    endIndex  = startIndex+nRandomPoints-1;
    
    randomPoints(startIndex:endIndex,:) = ...
        getrandompointsinmesh(primaryParticle.mesh,nRandomPoints);
    
    weights(startIndex:endIndex) = primaryParticle.bulkDensity;
    
    startIndex = endIndex+1;
end
end

