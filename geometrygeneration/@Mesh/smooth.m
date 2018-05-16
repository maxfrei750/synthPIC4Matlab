function obj = smooth(obj,smoothingLevel)
% Validate input.
validateattributes( ...
    smoothingLevel, ...
    {'numeric'}, ...
    {'real','finite','nonnan','nonsparse','nonempty','scalar','integer','>=',0});

if smoothingLevel > 0
    [obj.vertices,obj.faces] = ...
        smoothMesh(obj.vertices,obj.faces,smoothingLevel);
end

end

