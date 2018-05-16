%% Initialize workspace.
clear
close all

rng(1);

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
    
    object = Geometry('dodecahedron',diameter);
    
    object.subdivisionLevel = 4;
    object.smoothingLevel = 1;
    object.rotationAxisDirection = rand(1,3);
    object.rotationAngleDegree = rand*360;

    object.position = [randd([0 imageWidth]) randd([0 imageHeight]) diameter/2];
    
    objectMesh = objectMesh+object.mesh;
end

%% Voxelize the mesh.
% xMin = floor(min(objectMesh.vertices(:,1)));
% xMax = ceil(max(objectMesh.vertices(:,1)));
% 
% nSteps
% 
% yMin = floor(min(objectMesh.vertices(:,2)));
% yMax = ceil(max(objectMesh.vertices(:,2)));
% 
% zMin = floor(min(objectMesh.vertices(:,3)));
% zMax = ceil(max(objectMesh.vertices(:,3)));


meshStruct = objectMesh.tostruct;

voxelArray = VOXELISE(1000,1000,200,meshStruct);
