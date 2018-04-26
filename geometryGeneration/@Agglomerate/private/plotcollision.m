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
obj_A.draw
obj_B.draw

% Update figure
drawnow

if doRotate
    % Rotate axis.
    view(get(gca,'View')+[1 0]);
end
end

