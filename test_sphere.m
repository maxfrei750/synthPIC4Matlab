clear
close all

rng(2);
tic;
position = [1500/2 1125/2 0];
diameter = 300;

deformationAmplitude = 20;

[vertices,faces] = createIcosphere(3);

vertices = vertices*radius+position;

% Clean up mesh.
%[vertices,faces] = clean(vertices,faces,'SelfIntersections','ignore');

% Calculate vertexNormals;
vertexNormals = meshVertexNormals(vertices, faces);
%vertexNormals(isnan(vertexNormals)) = 0;

% Generate random deformation.
nVertices = size(vertices,1);
deformationOffsets = vertexNormals.*(rand(nVertices,1)*deformationAmplitude);

% Apply the deformation.
vertices = vertices+deformationOffsets;

% Smooth the mesh.
%[vertices, faces] = smoothMesh(vertices,faces);
toc;
hMesh = drawMesh(vertices, faces);
view(3);axis equal; light; lighting gouraud;
hMesh.EdgeColor = 'none';

% figure
% cleanTemImage = rendercleantemimage(vertices,faces,0.01);
% imshow(cleanTemImage);