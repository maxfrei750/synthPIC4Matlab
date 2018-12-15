function mask = binarize(obj)
%BINARIZE Summary of this function goes here
%   Detailed explanation goes here

pixelData = gather(obj.pixelData);

% If all pixels of the mask are identical, then create an entirely true
% mask.
if all(pixelData(:) == pixelData(1))
    mask = true(obj.size);
else  
    mask = ~imbinarize(pixelData);
end

end

