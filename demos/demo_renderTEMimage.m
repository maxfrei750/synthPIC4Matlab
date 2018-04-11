%% Initialize workspace.
clear
close all

rng(7);

%% Parameters
tic;
imageWidth = 100;
imageHeight = 100;

nObjects = 2;
minMaxDiameter = [50 100];


%% Create geometry list.

objectMesh = Mesh.empty;

for iObject = 1:nObjects
    diameter = randd(minMaxDiameter);
    
    object = Geometry('sphere',diameter);
    
%     object.subdivisionLevel = 4;
%     object.smoothingLevel = 1;
%     object.rotationAxisDirection = rand(1,3);
%     object.rotationAngleDegree = rand*360;

    object.position = [randd([0 imageWidth]) randd([0 imageHeight]) randd([0 200])];
    
    objectMesh = objectMesh+object.mesh;
end

%% Render clean TEM image.

cleanTemImage = ...
    rendercleantemimage( ...
    objectMesh, ...
    imageWidth, ...
    imageHeight, ...
    'transmissionCoefficient',0.01, ...
    'tileSize',250, ...
    'relativeResolution',1);

imshow(cleanTemImage);

toc;

% %% Post processing.
% distortedSemImage = cleanSemImage;
% 
% 
% % Add a background texture.
% backgroundTextureScale = [1 1];
% 
% backgroundTexture = fbm(ceil(imageHeight/backgroundTextureScale(2)),ceil(imageWidth/backgroundTextureScale(1)))+0.2;
% backgroundTexture = imresize(backgroundTexture,[imageHeight imageWidth]);
% backgroundTexture = imcomplement(imcomplement(backgroundTexture).*imcomplement(objectMask));
% 
% distortedSemImage = distortedSemImage.*backgroundTexture;
% 
% % Add blur.
% distortedSemImage = imgaussfilt(distortedSemImage,1);
% 
% % Add noise.
% distortedSemImage = imnoise(distortedSemImage,'gaussian',0,0.001);
% 
% figure
% montage(cellfun(@(x) gather(x),{diffuseMap,shadowMap,curvatureMap,cleanSemImage},'UniformOutput',false));
% 
% figure
% imshow(distortedSemImage);
% % imshow(shadowMap);
