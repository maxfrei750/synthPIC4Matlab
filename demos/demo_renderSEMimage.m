%% Initialize workspace.
clear
close all

rng(8);

%% Parameters
tic;
imageWidth = 1280;
imageHeight = 960;

nObjects = 10;
minMaxDiameter = [50 100];

diffuseStrength = 0.9;
shadowStrength = 0.5;
curvatureStrength = 0.3;

shadowOffset_max = 20;

backgroundColor = 0.2;
particleColor = 0.9;

%% Create geometry list.

objectMesh = Mesh;

for iObject = 1:nObjects
    diameter = randd(minMaxDiameter);
    
    object = Geometry('dodecahedron',diameter);
    
    object.subdivisionLevel = 4;
    object.smoothingLevel = 1;
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

if curvatureStrength > 0
    curvatureMap = rendercurvaturemap(completeMesh,imageWidth,imageHeight);
else
    curvatureMap = zeros(imageHeight,imageWidth);
end

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
    curvatureStrength*curvatureMap;

toc;

%% Post processing.
distortedSemImage = cleanSemImage;


% Add a background texture.
backgroundTextureScale = [1 1];

backgroundTexture = fbm(ceil(imageHeight/backgroundTextureScale(2)),ceil(imageWidth/backgroundTextureScale(1)))+0.2;
backgroundTexture = imresize(backgroundTexture,[imageHeight imageWidth]);
backgroundTexture = imcomplement(imcomplement(backgroundTexture).*imcomplement(objectMask));

distortedSemImage = distortedSemImage.*backgroundTexture;

% Add blur.
distortedSemImage = imgaussfilt(distortedSemImage,1);

% Add noise.
distortedSemImage = imnoise(distortedSemImage,'gaussian',0,0.001);

figure
montage(cellfun(@(x) gather(x),{diffuseMap,shadowMap,curvatureMap,cleanSemImage},'UniformOutput',false));

figure
imshow(distortedSemImage);
% imshow(shadowMap);
