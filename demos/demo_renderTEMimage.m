%% Initialize workspace.
clear
close all

for randomSeed = 1:1
rng(randomSeed);

%% Parameters
tic;
imageWidth = 1280;
imageHeight = 960;

nObjects = 30;
minMaxDiameter = [50 100];


%% Create geometry list.

objectMesh = Mesh.empty;

for iObject = 1:nObjects
    diameter = randd(minMaxDiameter);
    
    object = Geometry('sphere',diameter);
    
%     object.subdivisionLevel = 1;
%     object.smoothingLevel = 0;
%     object.rotationAxisDirection = rand(1,3);
%     object.rotationAngleDegree = rand*360;

    object.position = [randd([0 imageWidth]) randd([0 imageHeight]) randd([0 diameter])];
    
    objectMesh = objectMesh+object.mesh;
end

%% Render clean TEM image.

cleanTemImage = ...
    rendercleantemimage( ...
    objectMesh, ...
    imageWidth, ...
    imageHeight, ...
    'transmissionCoefficient',0.01, ...
    'tileSize',64, ...
    'relativeResolution',1);

figure
imshow(cleanTemImage);

toc;
end

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
% imshow(shadowMap);
