function binaryObjectMap = renderbinaryobjectmap(obj)
%RENDERBINARYOBJECTMAP Summary of this function goes here
%   Detailed explanation goes here

objectMap = obj.renderobjectmap;

binaryObjectMap = objectMap > 0;
end

