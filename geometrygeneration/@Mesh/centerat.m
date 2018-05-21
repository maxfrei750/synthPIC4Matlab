function obj = centerat(obj,position)
%CENTERATORIGIN Summary of this function goes here
%   Detailed explanation goes here

% If position has only two elements, then assume that the third element is
% zero.
if numel(position) == 2
    position(end+1) = 0;
end

% Validate input.
validateattributes( ...
    position, ...
    {'numeric'}, ...
    {'real','finite','nonnan','nonsparse','nonempty','row','vector','numel',3});

obj = obj.translate(position-obj.centroid);
end

