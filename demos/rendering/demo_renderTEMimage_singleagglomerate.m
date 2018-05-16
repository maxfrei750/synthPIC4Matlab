%% Initialize workspace.
clear
close all

rng(2);

%% Parameters

% Agglomerate parameters
agglomerationMode = 'BCCA';

d_g = 100;
s_g = 1.2;

diameterDistribution = makedist( ...
    'lognormal', ...
    'mu',log(d_g), ...
    'sigma',log(s_g));

nPrimaryParticles = 3;

% Image parameters
margin = 20;
transmissionCoefficient = 0.01;

% Rendering parameters
tileSize = 128;
relativeResolution = 0.5;

%% Geometry generation

% Create fraction.
fraction = Fraction('sphere',diameterDistribution);

fraction.subdivisionLevel = 3;
fraction.smoothingLevel = 3;

fraction.displacementLayers = Displacement('simplex');
fraction.displacementLayers.strength = 20;
fraction.displacementLayers.scale = 25;

% Create agglomerate.
agglomerate = Agglomerate(agglomerationMode,fraction,nPrimaryParticles);

% Get mesh of the agglomerate.
objectMesh = agglomerate.completeMesh;

%% Rendering
% Get necessary image size.
imageSize = round(objectMesh.boundingBox.dimensions(1:2))+margin*2;

imageWidth = imageSize(1);
imageHeight = imageSize(2);

% Place objectMesh, i.e. the agglomerate, in the center of the image.
translationVector = ...
    [imageWidth/2 imageHeight/2 objectMesh.boundingBox.dimensions(3)/2] - ...
    objectMesh.boundingBox.centroid;

objectMesh = objectMesh.translate(translationVector);

% Render clean TEM image.
cleanTemImage = ...
    rendercleantemimage( ...
    objectMesh, ...
    imageWidth, ...
    imageHeight, ...
    'transmissionCoefficient',transmissionCoefficient, ...
    'tileSize',tileSize, ...
    'relativeResolution',relativeResolution);

figure
imshow(cleanTemImage)

%% Post processing.
distortedTemImage = cleanTemImage;

% Add a background texture.
backgroundNoiseScale = [5 5];

noiseWidth = round(imageWidth/backgroundNoiseScale(2));
noiseHeight = round(imageHeight/backgroundNoiseScale(1));

background  = mat2gray(randn(noiseHeight,noiseWidth));
background = background-0.5;
background = background*0.1;
background = background+0.8;
background = clip(background,0,1);

% Clip noise.
background = clip(background,0,1);

background = imresize(background,[imageHeight imageWidth]);

distortedTemImage = distortedTemImage.*background;

% Add blur.
distortedTemImage = imgaussfilt(distortedTemImage,1);

% Add noise.
distortedTemImage = imnoise(distortedTemImage,'gaussian',0,0.0001);

figure
imshow(distortedTemImage);
