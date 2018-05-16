
nSides = 36;
height = 100;
diameter = 20;

UnitsPerSubdivision = 20;

subdivisionLevel_height = ceil(height/UnitsPerSubdivision);
subdivisionLevel_caps = ceil(diameter/UnitsPerSubdivision);

% Create primitives.
vertices_cap = ...
    createPolygonDiskVertices(nSides,subdivisionLevel_caps)*diameter;
vertices_ring = ...
    createPolygonVertices(nSides)*diameter;

zSteps = linspace(-height/2,height/2,subdivisionLevel_height+1);

% Create top and bottom caps based on the cap primitive.
vertices_cap_bottom = vertices_cap+[0 0 zSteps(1)];
vertices_cap_top = vertices_cap+[0 0 zSteps(end)];

% Preallocate array for vertices.
nVertices_rings = nSides*subdivisionLevel_height-1;
vertices_rings = zeros(nVertices_rings,3);

for iRing = 1:subdivisionLevel_height-1
    zStep = zSteps(iRing+1);
    
    startIndex = (iRing-1)*nSides+1;
    stopIndex = iRing*nSides;
    
    vertices_rings(startIndex:stopIndex,:) = vertices_ring+[0 0 zStep];
end

vertices = [vertices_cap_bottom;vertices_rings;vertices_cap_top];

faces = convhull(vertices(:,1),vertices(:,2),vertices(:,3));
toc;
drawMesh(vertices,faces);
axis equal 