clear
close all

% Ensure reproducibility.
rng(3); 

%% Generate a mesh of an agglomerate.

% Define agglomerate properties.
primaryParticleType = 'sphere'; % For other types see 'doc Fraction'.
nPrimaryParticles = 3; % Number of primary particles in the agglomerate.
agglomerationMode = 'DLA'; % Diffusion limited agglomeration (DLA).

% Define a size distribution for the generation of primary particles.
d_g = 100;
s_g = 1.5;

diameterDistribution = makedist( ...
    'lognormal', ...
    'mu',log(d_g), ...
    'sigma',log(s_g));

% Create a particle fraction and define its properties.
fraction = Fraction(primaryParticleType,diameterDistribution);

fraction.displacementLayers = Displacement('simplex');
fraction.displacementLayers.strength = 10;
fraction.displacementLayers.scale = 100;

% Perform the agglomeration by creating an agglomerate-object.
agglomerate = Agglomerate(agglomerationMode,fraction,nPrimaryParticles);

% Retrieve the complete mesh of the agglomerate.
mesh = agglomerate.completeMesh;

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

finalImage = gather(image.pixelData);

%% Collect the target data.

%% Complete mask of the image. E.g. for semantic segmentation.
completeMask = gather(renderScene.renderbinaryobjectmap);

% Display original image and mask.
figure('Name','Complete Mask');
imshowpair(finalImage,completeMask);

%% Boundingboxes of the individual particles.

% Retrieve boundingBoxes.
boundingBoxes = mesh.subBoundingBoxes2d;

% Display original image with boundingBoxes.
annotatedImage = finalImage;

nBoundingBoxes = size(boundingBoxes,1);

for iBoundingBox = 1:nBoundingBoxes
    boundingBox = boundingBoxes(iBoundingBox,:);
    annotatedImage = insertObjectAnnotation( ...
        annotatedImage, ...
        'rectangle',boundingBox, ...
        num2str(iBoundingBox));
end

figure('Name','Boundingboxes');
imshow(annotatedImage);

%% Masks of the individual particles Display subMasks.
subMasks = mesh.subMasks;
nSubMasks = size(subMasks,1);

for iSubMask = 1:nSubMasks
    subMask = subMasks{iSubMask};
    figure('Name',num2str(iSubMask));
    imshow(subMask);
end


