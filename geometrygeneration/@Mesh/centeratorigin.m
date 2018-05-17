function obj = centeratorigin(obj)
%CENTERATORIGIN Summary of this function goes here
%   Detailed explanation goes here
obj = obj.translate(-obj.centroid);
end

