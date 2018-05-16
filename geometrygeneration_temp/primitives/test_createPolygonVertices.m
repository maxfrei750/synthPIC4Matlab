clear
close all

nSides = 5;
r = 0.5;
t = linspace(0,2*pi,nSides+1);
t(end) = [];

x = r*cos(t);
y = r*sin(t);
z = zeros(1,nSides);

vertices = [x' y' z'];

% Add a vertex at the origin.
vertices = [vertices;[0 0 0]];

% Set up faces.
faces = [ ...
    repmat(nSides+1,1,nSides); ...
    (1:nSides); ...
    [2:nSides 1]]';


drawMesh(vertices,faces);

meshFaceNormals(vertices,faces);