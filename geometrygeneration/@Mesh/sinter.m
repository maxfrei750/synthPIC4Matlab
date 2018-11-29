function obj = sinter(obj,nSinterSteps)
%SINTER Summary of this function goes here
%   Detailed explanation goes here

% Validate input.
validateattributes( ...
    nSinterSteps, ...
    {'numeric'}, ...
    {'real','finite','nonnan','nonsparse','nonempty','scalar','integer','>=',0});

% If nSinterSteps is zero, then there's nothing to do.
if nSinterSteps == 0
    return;
end

tempVertices = obj.vertices;
tempFaces = obj.faces;

% [tempVertices,tempFaces] = outer_hull(tempVertices,tempFaces);
[tempVertices,tempFaces] = outer_hull(tempVertices,tempFaces);

for iSinterStep = 1:nSinterSteps
    % Get curvatures of vertices.
    c = discrete_gaussian_curvature(tempVertices,tempFaces);
    
    % Clip and invert vertex curvatures.
    c = -clip(c,-inf,0);
    
    % Get vertexnormals.
    n = per_vertex_normals(tempVertices,tempFaces);
    
    % Calculate sintering offsets.
    offsets = n.*c;
    
    % Apply offset.
    tempVertices = tempVertices+offsets;
end

% Fix scale.
tempDimensions = range(tempVertices);
tempScale = tempDimensions./obj.boundingBox.dimensions;
tempVertices = tempVertices./tempScale;

% Create a new mesh.
sinteredMesh = Mesh(tempVertices,tempFaces);

% Fix position.
sinteredMesh = sinteredMesh.centerat(obj.centroid);

% Replace the mesh with the sintered version.
obj = sinteredMesh;
end

