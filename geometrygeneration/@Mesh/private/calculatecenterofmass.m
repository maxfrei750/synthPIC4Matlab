function centerOfMass = calculatecenterofmass(obj)
%CALCULATECENTEROFMASS Summary of this function goes here
%   Detailed explanation goes here

nRandomPointsInVolume = 10000;

randomPointsInVolume = ...
    getrandompointsinmesh(obj,nRandomPointsInVolume);

% DEBUGGING
% scatter3( ...
%     randomPointsInVolume(:,1), ...
%     randomPointsInVolume(:,2), ...
%     randomPointsInVolume(:,3));
% 
% hold on
% obj.draw
% hold off

centerOfMass = mean(randomPointsInVolume);

end

