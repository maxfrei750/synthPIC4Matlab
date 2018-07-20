function saveimagestack(imageStack,folderPath,fileNameSuffix)
%SAVEIMAGESTACK Summary of this function goes here
%   Detailed explanation goes here

% Create folderPath if necessary.
createdirectory(folderPath);

% Get number of masks.
nImages = numel(imageStack);

% Iterate and save all masks.
for iImage = 1:nImages
    image = imageStack{iImage};
    
    image = gather(image);
    
    fileName = sprintf('%s%06d.png',fileNameSuffix,iImage);
    path = fullfile(folderPath,fileName);
    
    imwrite(image,path);
end

end

