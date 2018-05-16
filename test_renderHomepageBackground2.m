%% Initialize workspace.
clear
close all

randomSeed = 3;
rng(randomSeed);

%% Parameters
imageWidth = 1500;
imageHeight = 1125;

nObjects = 20;
minMaxDiameter = [50 100];
deformationAmplitude = 20;


%% Create geometry list.

objectMesh = Mesh.empty;

for iObject = 1:nObjects
    diameter = randd(minMaxDiameter);
    
    object = Geometry('sphere',diameter);
    
     object.subdivisionLevel = 2;
%     object.smoothingLevel = 0;
    object.rotationAxisDirection = rand(1,3);
    object.rotationAngleDegree = rand*360;

    object.position = [randd([0 imageWidth]) randd([0 imageHeight]) diameter/2];
    
    objectMesh = objectMesh+object.mesh;
end

vertices = objectMesh.vertices;
faces = objectMesh.faces;

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

% hMesh = drawMesh(vertices, faces);
% view(3); light; lighting gouraud;
% hMesh.EdgeColor = 'none';
% daspect([1 1 1])
% ylim([0 imageHeight]);
% xlim([0 imageWidth]);
% view(2)



%% render tem image

cleanTemImage = rendercleantemimage(...
    mesh, ...
    imageWidth,imageHeight, ...
    'transmissionCoefficient',0.01, ...
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
