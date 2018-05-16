clear
close all

tic;
r_max = 10;
subdivisionLevel = 10;

nSides = 72;

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

faces = [];

% Construct faces
for iSubdivision = 1:subdivisionLevel-1
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

last_faces = last_faces+nSides*(subdivisionLevel-1);

faces = [faces;last_faces];
toc;

% scatter3(vertices(:,1),vertices(:,2),vertices(:,3))
drawMesh(vertices,faces);
