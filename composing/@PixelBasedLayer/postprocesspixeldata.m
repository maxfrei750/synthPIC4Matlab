function pixelData = postprocesspixeldata(obj,pixelData)
%POSTPROCESSPIXELDATA Summary of this function goes here
%   Detailed explanation goes here

% Use GPU, if available and desired.
if obj.parent.useGpu && isgpuavailable
    pixelData = gpuArray(pixelData);
else
    pixelData = gather(pixelData);
end

% Apply inversion
if obj.inverted
    pixelData = 1-pixelData;
end

% Apply strength.
pixelData = pixelData*obj.strength;

% Apply brightness.
pixelData = pixelData+obj.brightness-0.5;

% Clip image.
pixelData = clip(pixelData,obj.clipping);

% Apply blur.
if obj.blurStrength > 0
    pixelData = imgaussfilt(pixelData,obj.blurStrength);
end

end

