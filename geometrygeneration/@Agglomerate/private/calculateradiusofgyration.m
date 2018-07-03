function radiusOfGyration = calculateradiusofgyration(obj)
%CALCULATERADIUSOFGYRATION Summary of this function goes here
%   Detailed explanation goes here

% Get uniformly sampled random points in the volume of the object.
[randomPoints,weights] = getrandompointsinvolume(obj);

% Calulate center of mass.
centerOfMass = wmean(randomPoints,repmat(weights,1,3),1);

% Calculate distances of the random points to the center of mass.
squaredDistancesToCenterOfMass = ...
    sum((randomPoints-centerOfMass).^2,2);

% Calculate moment of inertia of the distributed mass
% see https://www.engineeringtoolbox.com/moment-inertia-torque-d_913.html
momentOfInertia = ...
    sum(squaredDistancesToCenterOfMass.*weights);

% Calculate the radius of gyration.
radiusOfGyration = sqrt(momentOfInertia/sum(weights));

% % Plot radius of gyration.
% obj.draw
% 
% [x,y,z] = sphere;
% 
% r = radiusOfGyration;
% 
% Mx = centerOfMass(1);
% My = centerOfMass(2);
% Mz = centerOfMass(3);
% 
% m = surf(r*x+Mx, r*y+My, r*z+Mz);
% set(m,'facecolor','none')
end

