% Define a sphere.
sphere = Geometry('sphere',100);
sphere.position = [100 100 100];

% Define a dodecahedron.
dodecahedron = Geometry('dodecahedron',50);
dodecahedron.subdivisionLevel = 1;
dodecahedron.smoothingLevel = 0;
dodecahedron.rotationAxisDirection = [0 0 1];
dodecahedron.rotationAngleDegree = 30;

% Draw objects.
hSphere = sphere.draw('objectID');
hDodecahedron = dodecahedron.draw('objectID');

% Set display options.
daspect([1 1 1]);
view(3);