clear
close all

rng(2);
tic;

imageHeight = 1125;
imageWidth = 1500;

position = [imageWidth/2 imageHeight/2 0];
radius = 400;

deformationAmplitude = 50;

[vertices,faces] = createIcosphere(5);

vertices = vertices*radius+position;

% Calculate vertexNormals;
vertexNormals = meshVertexNormals(vertices, faces);

% Generate random deformation.
nVertices = size(vertices,1);
deformationOffsets = vertexNormals.*(rand(nVertices,1)*deformationAmplitude);

% Apply the deformation.
vertices = vertices+deformationOffsets;

% Smooth the mesh.
[vertices, faces] = smoothMesh(vertices,faces);
mesh = Mesh(vertices,faces);

toc;
hMesh = drawMesh(vertices, faces);
view(3); light; lighting gouraud;
hMesh.EdgeColor = 'none';
daspect([1 1 1])
ylim([0 imageHeight]);
xlim([0 imageWidth]);
view(2)


%% render tem image

cleanTemImage = rendercleantemimage(...
    mesh, ...
    imageWidth,imageHeight, ...
    'transmissionCoefficient',0.002, ...
    'tileSize',64, ...
    'relativeResolution',1);

figure
imshow(cleanTemImage);

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
