function centerOfMass = calculatecenterofmass(obj)
%CALCULATECENTEROFMASS Calculates the center of mass of the object.
%   Detailed explanation goes here

[randomPoints,weights] = getrandompointsinvolume(obj);

% Calulate mean of the random points, weighted by thedensity of the
% respective particles.
centerOfMass = wmean(randomPoints,repmat(weights,1,3),1);
end

