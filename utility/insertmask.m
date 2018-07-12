function image = insertmask(baseImage,mask,boundingBox)

% Validate |baseImage|.
validateattributes( ...
    baseImage, ...
    {'int16','logical','single','double','uint16', 'uint8'}, ...
    {'real','nonsparse'}, ...
    mfilename, ...
    'baseImage',1);
    
% Validate |mask|.
validateattributes( ...
    mask, ...
    {'int16','logical','single','double','uint16', 'uint8'}, ...
    {'nonsparse','2d','binary'}, ...
    mfilename, ...
    'mask',2);

% Validate |boundingBox|
validateattributes( ...
    boundingBox, ...
    {'numeric'}, ...
    {'nonsparse','vector','numel',4}, ...
    mfilename, ...
    'boundingBox',3);

% Round boundingBox down.
boundingBox = floor(boundingBox);
    
% Store datatype of the baseImage, so that it can be restored later.
originalDatatype = class(baseImage);

% Convert |baseImage| into single.
baseImage = im2double(baseImage);

% Get number of channels of the input image.
[~,~,nChannels] = size(baseImage);

% Get height and width of the mask.
[maskHeight,maskWidth] = size(mask);

% Determine boundingbox of the mask.
xMin = boundingBox(1);
xMax = xMin+maskWidth-1;
yMin = boundingBox(2);
yMax = yMin+maskHeight-1;

% Trim mask to the dimensions of the input image.
[imageHeight,imageWidth] = size(baseImage);

trimTop = 1-yMin;
trimBottom = yMax-imageHeight;
trimLeft = 1-xMin;
trimRight = xMax-imageWidth;

mask = imtrim(mask,trimTop,trimBottom,trimLeft,trimRight);

xMin = clip(xMin,1,imageWidth);
xMax = clip(xMax,1,imageWidth);
yMin = clip(yMin,1,imageHeight);
yMax = clip(yMax,1,imageHeight);

% Insert the mask into the baseImage.
baseImage_part = baseImage(yMin:yMax,xMin:xMax,:);
baseImage_part(repmat(mask,1,1,nChannels)) = 1;

image = baseImage;
image(yMin:yMax,xMin:xMax,:) = baseImage_part;

% Restore original datatype of the baseImage.
image = im2datatype(image,originalDatatype);
end