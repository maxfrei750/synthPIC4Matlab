%% Initialize workspace.
clear
close all

rng(1);

%% Parameters
tic;
imageWidth = 1280;
imageHeight = 960;

nObjects = 30;
minMaxDiameter = [50 100];

diffuseStrength = 0.9;
shadowStrength = 0.5;
edgeGlowStrength = 0.9;
edgeGlowSize = 3;

shadowOffset_max = 100;

backgroundColor = 0.2;
particleColor = 0.85;

%% Create geometry list.

objectMesh = Mesh.empty;

for iObject = 1:nObjects
    diameter = randd(minMaxDiameter);
    
    object = Geometry('sphere',diameter);
    
%     object.subdivisionLevel = 1;
%     object.smoothingLevel = 0;
    object.rotationAxisDirection = rand(1,3);
    object.rotationAngleDegree = rand*360;

    object.position = [randd([0 imageWidth]) randd([0 imageHeight]) diameter/2];
    object.color = particleColor;
    
    objectMesh = objectMesh+object.mesh;
end

% Create floor
floor = Geometry('floor',[imageWidth imageHeight]);
floor.color = backgroundColor;

% Add the floor to the mesh. 
completeMesh = objectMesh+floor.mesh;

if diffuseStrength > 0
    diffuseMap = renderdiffusemap(completeMesh,imageWidth,imageHeight);
else
    diffuseMap = zeros(imageHeight,imageWidth);
end

%% Add edgeglow
%objectMask

edgeGlowMap = imgaussfilt(diffuseMap,1);

edgeGlowMap = imfilter(edgeGlowMap,fliplr(fspecial('sobel')'),'replicate');

edgeGlowMap(edgeGlowMap>0) = edgeGlowMap(edgeGlowMap>0)/max(edgeGlowMap(:));
edgeGlowMap(edgeGlowMap<0) = edgeGlowMap(edgeGlowMap<0)/min(edgeGlowMap(:));

edgeGlowMap = imgaussfilt(edgeGlowMap,edgeGlowSize);
edgeGlowMap = mat2gray(edgeGlowMap);


if shadowStrength > 0
    objectMask = renderobjectmask(objectMesh,imageWidth,imageHeight);
    shadowMap = rendershadowmap(objectMask,shadowOffset_max);
else
    shadowMap = ones(imageHeight,imageWidth);
end


%% Compose the image.
cleanSemImage = ...
    (diffuseStrength*diffuseMap).* ...
    (1-(shadowStrength*(1-shadowMap)))+ ...
    edgeGlowStrength*edgeGlowMap;

toc;

%% Post processing.
distortedSemImage = cleanSemImage;


% Add a background texture.
backgroundTextureScale = [1 1];

backgroundTexture = fbm(ceil(imageHeight/backgroundTextureScale(2)),ceil(imageWidth/backgroundTextureScale(1)))+0.2;
backgroundTexture = imresize(backgroundTexture,[imageHeight imageWidth]);
backgroundTexture = imcomplement(imcomplement(backgroundTexture).*imcomplement(objectMask));
backgroundTexture = imgaussfilt(backgroundTexture,50);

distortedSemImage = distortedSemImage.*backgroundTexture;

% Add blur.
distortedSemImage = imgaussfilt(distortedSemImage,0.5);

% Add noise.
distortedSemImage = imnoise(distortedSemImage,'gaussian',0,0.0005);

figure
montage(cellfun(@(x) gather(x),{diffuseMap,shadowMap,edgeGlowMap,cleanSemImage},'UniformOutput',false));

figure
imshow(distortedSemImage);
% imshow(shadowMap);
imwrite(gather(distortedSemImage),'distortedSemImage.png');


