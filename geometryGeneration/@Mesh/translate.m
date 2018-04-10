function obj = translate(obj,translationVector)
% Validate inputs
validateattributes( ...
    translationVector, ...
    {'numeric'}, ...
    {'real','finite','nonnan','nonsparse','nonempty','row','vector','numel',3});

% Perform translation.
obj.vertices = obj.vertices+translationVector;
end