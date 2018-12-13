function transmissionMap = rendertransmissionmap(obj,transmissionCoefficient)
%RENDERTRANSMISSIONMAP Calculates the relative transmission intensities.
%   Source: Hornbogen, Skrotzki: Mikro- und Nanoskopie der Werkstoffe

% Set default value for transmissionCoefficient.
if nargin<2
    transmissionCoefficient = 0.005;
end

% Validate input.
validateattributes( ...
    transmissionCoefficient, ...
    {'numeric'}, ...
    {'real','finite','nonnan','nonsparse','nonempty','scalar','positive'});

% TODO: Render meshes with different bulkdensities individually and
% calculate the transmssion accordingly.

transmissionLengthMap = obj.rendertransmissionlengthmap;

% Calculate transmission intensity map.
transmissionMap = ...
    exp(-transmissionCoefficient*transmissionLengthMap);

end

