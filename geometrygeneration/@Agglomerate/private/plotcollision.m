function plotcollision(obj_A,obj_B,doRotate)
%PLOTCOLLISION Summary of this function goes here

if nargin<3
    doRotate = false;
end

% Validate input.
validateattributes( ...
    doRotate, ...
    {'logical'}, ...
    {'finite','nonnan','nonsparse','nonempty','scalar'});

% Clear current axis.
cla

% Draw objects.
hObjA = obj_A.draw;
hObjA.EdgeColor = 'none';

hObjB = obj_B.draw;
hObjB.EdgeColor = 'none';

% Update figure
drawnow

if doRotate
    % Rotate axis.
    view(get(gca,'View')+[3 0]);
end
end

