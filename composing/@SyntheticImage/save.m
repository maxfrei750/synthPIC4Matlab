function save(obj,path)
%SAVE Summary of this function goes here
%   Detailed explanation goes here

[baseDirectory,~,~] = fileparts(path);

createdirectory(baseDirectory);

data = gather(obj.pixelData);

imwrite(data,path);
end

