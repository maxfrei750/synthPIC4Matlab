clear
close all



g = Geometry('tetrakaidecahedron');

s = Geometry('sphere');

vertices = g.mesh.vertices;

maxDimension = max(max(vertices)-min(vertices));

scalingFactor = 1/maxDimension;

g.scale = scalingFactor;

hPatch = g.draw;
s.draw([0 0 0])

% Set display options.
hPatch.EdgeColor = [0 0 0];


daspect([1 1 1]);
view(3);