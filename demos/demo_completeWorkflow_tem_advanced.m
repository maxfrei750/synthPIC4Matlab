%% Preparations
clear
close all

% Ensure reproducibility.
rng(3); 

%% Generate a mesh of an agglomerate.

% Define agglomerate properties.
nPrimaryParticles = 10; % Number of primary particles in the agglomerate.
agglomerationMode = 'BCCA'; % Diffusion limited agglomeration (DLA).

% Define fraction1.
d_g_spheres = 100;
s_g_spheres = 1.2;

diameterDistribution_spheres = makedist( ...
    'lognormal', ...
    'mu',log(d_g_spheres), ...
    'sigma',log(s_g_spheres));

fraction1 = Fraction('sphere',diameterDistribution_spheres);

fraction1.color = 0.75;

fraction1.displacementLayers = Displacement('simplex');
fraction1.displacementLayers.strength = 4;
fraction1.displacementLayers.scale = 20;

% Define fraction2.
d_g_cubes = 50;
s_g_cubes = 1.1;

scaleDistribution_cubes = makedist( ...
    'lognormal', ...
    'mu',log(d_g_cubes), ...
    'sigma',log(s_g_cubes));

fraction2 = Fraction('cube',scaleDistribution_cubes);

fraction2.color = 0.75;
fraction2.subdivisionLevel = 10;
fraction2.smoothingLevel = 2;
fraction2.bulkDensity = 2;

% Create a fraction list.
fractionList = [fraction1 fraction2];

% Perform the agglomeration by creating an agglomerate-object.
agglomerate = Agglomerate(agglomerationMode,fractionList,nPrimaryParticles);

% Retrieve the complete mesh of the agglomerate.
mesh = agglomerate.completeMesh;

% Optional: Plot the mesh.
figure
mesh.draw('objectID'); % 'objectID': Color the individual primary particles.
title('Mesh');

%% Render the agglomerate.

% Define the parameters of the render scene.
imageSize = [400 600]; %[height(y-axis) width(x-axis)]
transmissionCoefficient = 0.005;

% Position the mesh at the center of the image.
mesh = mesh.centerat([imageSize(2)/2 imageSize(1)/2 0]); % [x y z]

% Create a RenderScene-object.
renderScene = RenderScene(mesh,imageSize);

% Retrieve the desired render passes (maps).
transmissionMap = ...
    renderScene.rendertransmissionmap(transmissionCoefficient);

% Optional: Show the retrieved map.
figure
imshow(transmissionMap);

%% Compose the image.

% Create a syntheticImage-object.
image = SyntheticImage(renderScene.imageSize);

% Add a background
bg = ColorLayer;
bg.color = 0.8;
bg.blendMode = 'add';

image.addlayer(bg);

% Add a background noise
backgroundNoise = NoiseLayer;
backgroundNoise.type = 'gaussian';
backgroundNoise.blendMode = 'add';
backgroundNoise.scale = 3;
backgroundNoise.strength = 0.01;
backgroundNoise.blurStrength = 1;

image.addlayer(backgroundNoise);

% Add a layer showing the agglomerate.
agglomerateImage = ImageLayer(transmissionMap);
agglomerateImage.blurStrength = 1.5;
image.addlayer(agglomerateImage);

% Create a foreground noise.
foregroundNoise = NoiseLayer;
foregroundNoise.type = 'gaussian';
foregroundNoise.blendMode = 'add';
foregroundNoise.scale = 1;
foregroundNoise.strength = 0.01;

image.addlayer(foregroundNoise);

% Optional: Show the synthetic image.
figure
image.show
