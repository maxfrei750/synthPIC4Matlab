function vertices = createPolygonDiskVertices(nSides,subdivisionLevel)
%CREATEPOLYGONDISKVERTICES Summary of this function goes here
%   Detailed explanation goes here

% Validation of nSides is performed in createPolygonVertices.

% Validate subdivisionLevel.
validateattributes( ...
    subdivisionLevel, ...
    {'numeric'}, ...
    {'real','finite','nonnan','nonsparse','nonempty','integer','scalar','positive'});

if nargin<2
    subdivisionLevel = 1;
end

r_max = 1;

polygonPrimitiveVertices = createPolygonVertices(nSides);

r_steps = linspace(0,r_max,subdivisionLevel+1);
r_steps(1) = [];

vertices = zeros(nSides*subdivisionLevel,3);

for iSubdivision = 1:subdivisionLevel
    r = r_steps(iSubdivision);
    
    index_start = (iSubdivision-1)*nSides+1;
    index_stop = iSubdivision*nSides;
    
    vertices(index_start:index_stop,:) = polygonPrimitiveVertices*r;
end

% Add center point.

vertices = [vertices;[0 0 0]];

end

