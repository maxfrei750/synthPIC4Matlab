%% Initialize workspace.
clear
close all

rng(1);

%% Parameters
tic;
imageWidth = 100;
imageHeight = 100;

nObjects = 5;
minMaxDiameter = [20 50];

%% Create some geometry.
objectMesh = Mesh.empty;

for iObject = 1:nObjects
    diameter = randd(minMaxDiameter);
    
    object = Geometry('octahedron',diameter);
    
    object.subdivisionLevel = 1;
    object.smoothingLevel = 0;
    object.rotationAxisDirection = rand(1,3);
    object.rotationAngleDegree = rand*360;
    
    object.position = [randd([0 imageWidth*1.5]) randd([0 imageHeight*1.5]) diameter/2];
    
    objectMesh = objectMesh+object.mesh;
end

%% Extract vertices, faces from mesh.
vertices = objectMesh.vertices;
faces = objectMesh.faces;

vertices2D = vertices(:,1:2);
nFaces = size(faces,1);

P0 = vertices2D(faces(:,1),:);
P1 = vertices2D(faces(:,2),:);
P2 = vertices2D(faces(:,3),:);

xCoordinates = [P0(:,1);P1(:,1);P2(:,1)];
yCoordinates = [P0(:,2);P1(:,2);P2(:,2)];

%% Create Polyshapeobjects for the faces

% Preallocation.
faces_polyshape = polyshape(xCoordinates,yCoordinates);

% vertcat(faces_polyshape.Vertices)= vertices2D(faces);

