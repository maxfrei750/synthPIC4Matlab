function save(obj,path)
%SAVE Summary of this function goes here
%   Detailed explanation goes here

data = gather(obj.pixelData);

imwrite(data,path);
end

