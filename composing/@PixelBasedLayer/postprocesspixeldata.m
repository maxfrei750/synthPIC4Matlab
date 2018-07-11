function pixelData = postprocesspixeldata(obj,pixelData)
%POSTPROCESSPIXELDATA Summary of this function goes here
%   Detailed explanation goes here

% Use gpu, if available.
if isgpuavailable
    pixelData = gpuArray(pixelData);
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

% Apply inversion
if obj.inverted
    pixelData = 1-pixelData;
end

% Apply mask.
pixelData = pixelData.*obj.mask;


end

