function pixelData = postprocesspixeldata(obj,pixelData)
%POSTPROCESSPIXELDATA Summary of this function goes here
%   Detailed explanation goes here

% Clip image.
pixelData = clip(pixelData,[0 1]);

% Apply inversion
if obj.inverted
    pixelData = 1-pixelData;
end

% Apply blur.
if obj.blurStrength > 0
    pixelData = imgaussfilt(pixelData,obj.blurStrength);
end

end

