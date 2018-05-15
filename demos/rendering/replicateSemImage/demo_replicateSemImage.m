%% Initialize workspace.
clear
close all

%% Parameters
diffuseStrength = 0.5;
shadowStrength = 0.75;
edgeGlowStrength = 0.2;
edgeGlowSize = 1;

shadowOffset_max = 100;

backgroundColor = 0.1;
particleColor = 0.75;

%% Load real image.
realSemImage = gpuArray(im2double(imread('realSemImage.png')));
realParticleData = load('realSemImage_data.mat','Par_px');
realParticleData = realParticleData.Par_px;

% Preprocess real data.
[imageHeight,imageWidth] = size(realSemImage);
nParticles = numel(realParticleData);
diameters = vertcat(realParticleData.a)*2;
positions = [vertcat(realParticleData.X0) vertcat(realParticleData.Y0)];

%% Create geometry list.

objectMesh = Mesh.empty;

for iObject = 1:nParticles
    diameter = diameters(iObject);
    
    position = [positions(iObject,:) diameter/2];
    
    object = Geometry('sphere',diameter);

    object.position = position;
    object.color = particleColor;
    
    objectMesh = objectMesh+object.mesh;
end

% Create floor
floor = Geometry('floor',[imageWidth*2 imageHeight*2]);
floor.position = [-imageWidth/2 -imageHeight/2 0];
floor.color = backgroundColor;

% Add the floor to the mesh. 
completeMesh = objectMesh+floor.mesh;

% Render objectMask
[objectMask,objectMask_binary] = renderobjectmask(objectMesh,imageWidth,imageHeight);

% Render colorMap
colorMap = rendercolormap(completeMesh,imageWidth,imageHeight);

% imshow(insertShape(gather(colorMap),'rectangle',[positions(:,1:2)-diameters/2 diameters diameters],'Opacity',0.3));

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


% Add blur.
% distortedSemImage = imgaussfilt(distortedSemImage,0.4);

distortedSemImage = clip(distortedSemImage,0,1);


% figure
% montage(cellfun(@(x) gather(x),{diffuseMap,shadowMap,edgeGlowMap,cleanSemImage},'UniformOutput',false));

%% Create and display combined image.
combinedImage = realSemImage;
combinedImage(end/2+1:end,:) = distortedSemImage(end/2+1:end,:);

% combinedImage(:,1:4) = [];
% combinedImage(:,end-3:end) = [];
% 
% distortedSemImage(:,1:4) = [];
% distortedSemImage(:,end-3:end) = [];

figure
imshow(combinedImage);

% add annotations
hold on
hLine = plot([0 imageWidth],[imageHeight/2 imageHeight/2],'w--');
hText1 = text(imageWidth/2,imageHeight/2-50,'real SEM image','Color','white','FontSize',30,'HorizontalAlignment','center');
hText2 = text(imageWidth/2,imageHeight/2+50,'synthetic SEM image','Color','white','FontSize',30,'HorizontalAlignment','center');

% export_fig('comparison.png','-native');

imwrite(gather(distortedSemImage),'syntheticSemImage.png');

% figure
% imshow(insertShape(gather(combinedImage),'rectangle',[positions(:,1:2)-diameters/2 diameters diameters],'Opacity',0.3));

% imshow(shadowMap);
% imwrite(gather(distortedSemImage),'distortedSemImage.png');
