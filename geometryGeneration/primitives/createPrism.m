function varargout = createPrism(nSides,diameter,height)
%CREATEPRISM Creates a prism with nSides sides.
%   Optional: diameter and height can be specified (default: 1).

%% Set default values for diameter and height.
if nargin<3
    height = 1;
end

if nargin<2
    diameter = 1;
end

%% Parameter validation
% Validation of nSides is performed in createPolygonDisk.

% Validate diameter.
validateattributes( ...
    diameter, ...
    {'numeric'}, ...
    {'real','finite','nonnan','nonsparse','nonempty','scalar','positive'});

% Validate height.
validateattributes( ...
    height, ...
    {'numeric'}, ...
    {'real','finite','nonnan','nonsparse','nonempty','scalar','positive'});

%% Calculate appropriate subdivisions.
UnitsPerSubdivision = 20;

nSubdivisions_height = ceil(height/UnitsPerSubdivision*2);
nSubdivisions_caps = ceil(diameter/UnitsPerSubdivision);

%% Calculate number of vertices in the different parts of the geometry.
nVerticesPerRing = nSides;
nRings = nSubdivisions_height-1;
nVertices_rings = nVerticesPerRing*nRings;

nVerticesPerCap = nSides*nSubdivisions_caps+1;

%% Create top and bottom caps based on the cap primitive.

% Create cap primitive.
[vertices_cap,faces_cap] = createPolygonDisk(nSides,nSubdivisions_caps);

% Scale cap primitive.
vertices_cap = vertices_cap*diameter;

% Create top and bottom cap.
vertices_cap_bottom = vertices_cap;
vertices_cap_top = vertices_cap;

faces_cap_bottom = faces_cap;
faces_cap_top = faces_cap;

% Invert facenormals of the bottom cap.
faces_cap_bottom = fliplr(faces_cap_bottom);

% Translate vertices of the top and bottom cap.
zSteps = linspace(-height/2,height/2,nSubdivisions_height+1);

vertices_cap_bottom = vertices_cap_bottom+[0 0 zSteps(1)];
vertices_cap_top = vertices_cap_top+[0 0 zSteps(end)];

%% Create ring vertices.

% Create ring primitive
vertices_ring = createPolygonVertices(nSides);

% Scale ring primitive.
vertices_ring = vertices_ring*diameter;

vertices_rings = zeros(nVertices_rings,3);

for iRing = 1:nRings
    zStep = zSteps(iRing+1);
    
    startIndex = (iRing-1)*nSides+1;
    stopIndex = iRing*nSides;
    
    vertices_rings(startIndex:stopIndex,:) = vertices_ring+[0 0 zStep];
end

%% Combine vertices.
vertices = [vertices_cap_bottom; vertices_rings; vertices_cap_top];

%% Create ring faces as quads.

faces_rings = zeros(nSides*nSubdivisions_height,4);

for iSubdivision = 1:nSubdivisions_height
    
    if iSubdivision == 1
        firstFaceOfThisSubdivision = ...
            [1 2 nSides+3 nSides+2]+nSides*(iSubdivision-1);
    else
        firstFaceOfThisSubdivision = ...
            [1 2 nSides+2 nSides+1]+nSides*(iSubdivision-1)+1;
    end
    
    iSide = 1;
    iFace = nSides*(iSubdivision-1)+iSide;
    
    faces_rings(iFace,:) = firstFaceOfThisSubdivision;
    
    for iSide = 2:nSides-1
        currentFace = firstFaceOfThisSubdivision+iSide-1;
        
        iFace = nSides*(iSubdivision-1)+iSide;
        faces_rings(iFace,:) = currentFace;
    end
    
    % Face of last side
    if iSubdivision == 1
        lastFaceOfThisSubdivision = ...
            [nSides 1 nSides+2 nSides*2+1]+nSides*(iSubdivision-1);
    else
        lastFaceOfThisSubdivision = ...
            [nSides+1 2 nSides+2 nSides*2+1]+nSides*(iSubdivision-1);
    end
    
    iSide = nSides;
    iFace = nSides*(iSubdivision-1)+iSide;
    
    faces_rings(iFace,:) = lastFaceOfThisSubdivision;
end

% Dirty fix.
faces_rings(end-nSides+1:end,3:4) = faces_rings(end-nSides+1:end,3:4)+nVerticesPerCap-nSides-1;

% Convert quads to triangels.
faces_rings = triangulateFaces(faces_rings);

%% Adjust faces.
faces_rings = faces_rings+size(vertices_cap_bottom,1)-nSides-1;
faces_cap_top = faces_cap_top+size(vertices_cap_bottom,1)+size(vertices_rings,1);

faces = [faces_cap_bottom; faces_rings; faces_cap_top];

%% Assign outputs
switch nargout
    case {0, 1}
        mesh = Mesh(vertices,faces);
        varargout{1} = mesh;
    case 2
        varargout{1} = vertices;
        varargout{2} = faces;
    case 3
        varargout{1} = vertices;
        varargout{2} = faces;
        varargout{3} = meshEdges(faces);
    otherwise
        error('Expected 1, 2 or 3 outputs.');
end

end

