clear
close all

load('testRenderScene.mat');

image = SyntheticImage(renderScene.imageSize);

% Create background
bg = ColorLayer;
bg.color = 0.8;
bg.blendMode = 'add';

image.addlayer(bg);

% Create a background noise
backgroundNoise = NoiseLayer;
backgroundNoise.type = 'gaussian';
backgroundNoise.blendMode = 'add';
backgroundNoise.scale = 3;
backgroundNoise.strength = 0.01;
backgroundNoise.blurStrength = 1;

image.addlayer(backgroundNoise);

% Create layer showing the agglomerate.
agglomerateImage = ImageLayer(renderScene.rendertransmissionmap);
agglomerateImage.blurStrength = 1.5;
image.addlayer(agglomerateImage);

% Create a foreground noise.
foregroundNoise = NoiseLayer;
foregroundNoise.type = 'gaussian';
foregroundNoise.blendMode = 'add';
foregroundNoise.scale = 1;
foregroundNoise.strength = 0.01;

image.addlayer(foregroundNoise);

figure
image.show
