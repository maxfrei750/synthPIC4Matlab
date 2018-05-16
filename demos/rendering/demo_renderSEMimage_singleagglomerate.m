%% Initialize workspace.
clear
close all

rng(8);

%% Parameters

% Agglomerate parameters
agglomerationMode = 'BCCA';

d_g = 100;
s_g = 1.2;

diameterDistribution = makedist( ...
    'lognormal', ...
    'mu',log(d_g), ...
    'sigma',log(s_g));

nPrimaryParticles = 1;

% Image parameters
imageWidth = 500;
imageHeight = 500;

diffuseStrength = 0.5;
shadowStrength = 0.75;
edgeGlowStrength = 0.2;
edgeGlowSize = 1;

shadowOffset_max = 100;

backgroundColor = 0.1;
particleColor = 0.75;

%% Create geometry.
% Create agglomerate
fraction = Fraction('sphere',diameterDistribution);
fraction.color = particleColor;

agglomerate = Agglomerate(agglomerationMode,fraction,nPrimaryParticles,'agglomerationSpeed',20);

objectMesh = agglomerate.completeMesh;

objectMesh = objectMesh.translate([imageWidth/2 imageHeight/2 objectMesh.boundingBox.dimensions(3)]-objectMesh.boundingBox.centroid);

% Create floor
floor = Geometry('floor',[imageWidth imageHeight]);
floor.color = backgroundColor;

% Add the floor to the mesh. 
completeMesh = objectMesh+floor.mesh;

%% Render maps
% Render objectMask
[objectMask,objectMask_binary] = renderobjectmask(objectMesh,imageWidth,imageHeight);

% Render colorMap
colorMap = rendercolormap(completeMesh,imageWidth,imageHeight);

% Render diffuseMap.
diffuseMap = renderdiffusemap(completeMesh,imageWidth,imageHeight);

% Render edgeGlowMap.
edgeGlowMap = renderedgeglowmap(diffuseMap,colorMap,edgeGlowSize);

% Render shadowMap.
shadowMap = rendershadowmap(objectMask,shadowOffset_max);

%% Compose the image.
cleanSemImage = ...
    colorMap.* ...
    (1-(diffuseStrength*(1-diffuseMap))).* ...
    (1-(shadowStrength*(1-shadowMap)))+ ...
    edgeGlowStrength*edgeGlowMap;


%% Post processing.
distortedSemImage = cleanSemImage;

% Add a background texture.
backgroundTextureScale = [1 1];

rng(2)
backgroundTexture = fbm(ceil(imageHeight/backgroundTextureScale(2)),ceil(imageWidth/backgroundTextureScale(1)))+0.2;
backgroundTexture = imresize(backgroundTexture,[imageHeight imageWidth]);
backgroundTexture = imcomplement(imcomplement(backgroundTexture).*imcomplement(objectMask));
backgroundTexture = imgaussfilt(backgroundTexture,70);

distortedSemImage = distortedSemImage.*backgroundTexture;

% Add blur.
distortedSemImage = imgaussfilt(distortedSemImage,1);

% Add noise.
noise_particles = randn(imageHeight,imageWidth)*0.03;
noise_background = randn(imageHeight,imageWidth)*0.014;
distortedSemImage = distortedSemImage+noise_particles.*objectMask;
distortedSemImage = distortedSemImage+noise_background.*imcomplement(objectMask);
% distortedSemImage = imnoise(distortedSemImage,'gaussian',0,0.0007);

distortedSemImage = clip(distortedSemImage,0,1);


imshow(distortedSemImage)