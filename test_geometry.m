%% Initialize workspace.
clear
close all

rng(2);

%% Set parameters.
position = [0 0 0];
rotation = [10 20 30];
scale = 150;
nFaces_min = 2000;

deformationAmplitude = 7.5;
nSmoothingIterations = 3;

tic;

%% Generate geometry.
% [vertices,faces] = createIcosahedron;
%[vertices,faces] = createDodecahedron;
[vertices,faces] = createIcosphere;

% Triangulate faces.
faces = triangulateFaces(faces);

%% Scale the geometry.
vertices = vertices*scale;

%% Position the geometry.
vertices = vertices+position;

%% Rotate the geometry around the center of mass.
centerOfMass = mean(vertices);
rotationAxis_origin = centerOfMass;
rotationAxis_direction = rand(1,3);

rotationAxis = [rotationAxis_origin rotationAxis_direction];
rotationAngle = 2*pi*rand;

rotationMatrix = createRotation3dLineAngle(rotationAxis,rotationAngle);
nVertices = size(vertices,1);

for i = 1:nVertices
    vertices(i,:) = vertices(i,:)*rotationMatrix(1:3,1:3);
end

%% Subdivide the mesh for displacement and smoothing.
nFaces = size(faces,1);
subdivisionLevel = ceil(sqrt(nFaces_min/nFaces));

if subdivisionLevel>1
    [vertices,faces] = subdivideMesh(vertices,faces,subdivisionLevel);
end

%% Smooth the mesh.
[vertices, faces] = smoothMesh(vertices,faces,nSmoothingIterations);

%% Displace the vertices.
% Calculate vertexNormals;
vertexNormals = meshVertexNormals(vertices, faces);

% Generate random displacement.
nVertices = size(vertices,1);
deformationOffsets = vertexNormals.*(rand(nVertices,1)*deformationAmplitude);

% Apply the displacement.
vertices = vertices+deformationOffsets;

disp('Generation:');
toc;

%% Render TEM image.
tic;
disp('Rendering:');
cleanTemImage = rendercleantemimage(vertices,faces,0.008);
toc;

%% Show 3d view.
figure
hMesh = drawMesh(vertices, faces);
view(3);axis equal; light; lighting gouraud;
hMesh.EdgeColor = 'none';

%% Show clean TEM image.
figure
imshow(cleanTemImage);

%% Post process
distortedTemImage = padarray(cleanTemImage,[50 50],1);

[imageHeight,imageWidth] = size(distortedTemImage);

% Add blur.
distortedTemImage = imgaussfilt(distortedTemImage,1);

% Add background.
background = imresize(rand(30,30),[imageHeight,imageWidth]);
distortedTemImage = distortedTemImage.*(background*0.05+0.8);

% Add noise.
distortedTemImage = imnoise(distortedTemImage,'gaussian',0,0.0005);

imshow(distortedTemImage);