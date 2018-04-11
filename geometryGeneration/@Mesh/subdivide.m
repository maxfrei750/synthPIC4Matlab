function obj = subdivide(obj,subdivisionLevel)
% Validate input.
validateattributes( ...
    subdivisionLevel, ...
    {'numeric'}, ...
    {'real','finite','nonnan','nonsparse','nonempty','scalar','integer','>=',0});

if subdivisionLevel > 1
    [obj.vertices,obj.faces] = ...
        subdivideMesh(obj.vertices,obj.faces,subdivisionLevel);
    
    % Update facesObjectIDs
    facesObjectIDs_temp = repmat(obj.facesObjectIDs',subdivisionLevel^2,1);
    obj.facesObjectIDs = facesObjectIDs_temp(:);
end
end