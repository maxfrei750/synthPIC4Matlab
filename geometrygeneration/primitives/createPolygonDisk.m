function [vertices,faces] = createPolygonDisk(nSides,nSubdivisions)
%CREATEPOLYGONDISK Summary of this function goes here
%   Detailed explanation goes here
r_max = 1;

polygonPrimitiveVertices = createPolygonVertices(nSides);

r_steps = linspace(0,r_max,nSubdivisions+1);
r_steps(1) = [];

vertices = zeros(nSides*nSubdivisions,3);

for iSubdivision = 1:nSubdivisions
    r = r_steps(iSubdivision);
    
    index_start = (iSubdivision-1)*nSides+1;
    index_stop = iSubdivision*nSides;
    
    vertices(index_start:index_stop,:) = polygonPrimitiveVertices*r;
end

% Add center point.

vertices = [vertices;[0 0 0]];

faces = [];

% Construct faces
for iSubdivision = 1:nSubdivisions-1
    % Calulate minimum and maximum allowed vertexIndex for this
    % subdivisionLevel
    vertexIndex_min = (iSubdivision-1)*nSides+1;
    vertexIndex_max = (iSubdivision+1)*nSides;
    
    firstTriangleFaceOfQuad = [vertexIndex_min vertexIndex_min+1 vertexIndex_min+nSides+1]-1;
    secondTriangleFaceOfQuad = [vertexIndex_min vertexIndex_min+nSides+1 +vertexIndex_min+nSides]-1;
    
    % Iterate all quads but the last
    for iQuad = 1:nSides-1
        firstTriangleFaceOfQuad = firstTriangleFaceOfQuad+1;
        secondTriangleFaceOfQuad = secondTriangleFaceOfQuad+1;
        
        faces = [faces;firstTriangleFaceOfQuad;secondTriangleFaceOfQuad];
    end
    
    % The last quad is special
    iQuad = iSubdivision*nSides;
    firstTriangleFaceOfLastQuad = [iQuad vertexIndex_min vertexIndex_min+nSides];
    secondTriangleFaceOfLastQuad = [iQuad vertexIndex_min+nSides vertexIndex_max];
    
    faces = [faces;firstTriangleFaceOfLastQuad;secondTriangleFaceOfLastQuad];
    
    
%     faces = mod(faces-1,vertexIndex_max)+1;
end

% The faces of the last subdivision are special, because they are
% inherently triangles.

last_faces = [ ...
    repmat(nSides+1,1,nSides); ...
    (1:nSides); ...
    [2:nSides 1]]';

last_faces = last_faces+nSides*(nSubdivisions-1);

faces = [faces;last_faces];
end

