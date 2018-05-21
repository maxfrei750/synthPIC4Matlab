function pixelData = computepixeldata(obj)
%COMPUTEPIXELDATA Summary of this function goes here
%   Detailed explanation goes here

pixelData = ones(obj.parent.size)*obj.color;

% Use gpu, if available.
if isgpuavailable
    pixelData = gpuArray(pixelData);
end
end

