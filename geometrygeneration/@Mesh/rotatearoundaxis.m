function obj = rotatearoundaxis(obj,axisDirection,angleDegree,point)

% If no point is specified the, use the center of mass as turning point.
if nargin<4
    point = obj.centerOfMass;
end

% Validate inputs
validateattributes( ...
    axisDirection, ...
    {'numeric'}, ...
    {'real','finite','nonnan','nonsparse','nonempty','row','vector','numel',3});

validateattributes( ...
    angleDegree, ...
    {'numeric'}, ...
    {'real','finite','nonnan','nonsparse','nonempty','scalar'});

validateattributes( ...
    point, ...
    {'numeric'}, ...
    {'real','finite','nonnan','nonsparse','nonempty','row','vector','numel',3});



% Don't perform a rotation if the rotation angle is zero.
if angleDegree ~= 0
    % Rotation goes through the center of mass in the
    % specified direction.
    rotationAxis = ...
        [point axisDirection];
    
    % Calculate rotation matrix.
    rotationMatrix = createRotation3dLineAngle( ...
        rotationAxis, ...
        angleDegree/360*2*pi);
    
    rotationMatrix = rotationMatrix(1:3,1:3);
    
    obj.vertices = (rotationMatrix*obj.vertices')';
end
end