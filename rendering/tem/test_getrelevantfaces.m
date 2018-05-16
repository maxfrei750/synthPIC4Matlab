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

triangulationObject = triangulation(faces,vertices2D);

%% Create points to test.
x_min = 0;
x_max = imageWidth;

y_min = 0;
y_max = imageHeight;

% Calculate the coordinates of the pixels of the virtual imaging screen.
x_steps = linspace( ...
    0.5, ...
    imageWidth-0.5, ...
    imageWidth/2);

y_steps = linspace( ...
    0.5, ...
    imageHeight-0.5, ...
    imageHeight/2);

% Make a list of all the pixel coordinates.
[rayIncidentPoints_x,rayIncidentPoints_y]  = meshgrid(x_steps,y_steps);

rayIncidentPoints_x = rayIncidentPoints_x(:);
rayIncidentPoints_y = rayIncidentPoints_y(:);

%% Determine relevant triangles.
relevantFaceIndices = getrelevantfaces(vertices,faces,rayIncidentPoints_x,rayIncidentPoints_y);
toc;

%% Plot triangles
figure
hold on

colors = parula(5);

hPlotTile = plot([0 0 100 100 0],[0 100 100 0 0],'--');
hPlotTile.Color = colors(4,:);

hPlotRays = plot(rayIncidentPoints_x,rayIncidentPoints_y,'.','MarkerSize',6);
hPlotRays.Color = colors(2,:);

hPlotGeometry = triplot(triangulationObject);
hPlotGeometry.Color = colors(3,:);

hPlotRelevantFaces = triplot(triangulationObject.ConnectivityList(relevantFaceIndices,:),vertices2D(:,1),vertices2D(:,2),'--');
hPlotRelevantFaces.Color = colors(1,:);

xlim([0 200]);
ylim([0 200]);
xlabel('x-axis [pixel]');
ylabel('y-axis [pixel]');

ylabel('{\fontname{times}{\ity}}-coordinate [pixel]');
xlabel('{\fontname{times}{\itx}}-coordinate [pixel]');

[~,hIcons,~,~] = legend('tile','rays','geometry','relevant faces');
hIcons(8).MarkerSize = 25;

% image = rgb2gray(print('-RGBImage','-r300'));
% 
% figure
% imshow(image);