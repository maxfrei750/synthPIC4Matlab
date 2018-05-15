function obj = adddisplacementlayer(obj,displacementLayer)
%ADDDISPLACEMENTLAYER Summary of this function goes here
%   Detailed explanation goes here

% Validate input.
validateattributes( ...
    displacementLayer, ...
    {'Displacement'}, ...
    {'nonempty','scalar'});

obj.displacementLayers(end+1) = displacementLayer;
end

