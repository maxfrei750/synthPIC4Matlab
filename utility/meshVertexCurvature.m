function vertexCurvatures = meshVertexCurvature(vertices,faces)
%VERTEXCURVATURE Calculate curvature at vertices of a mesh.
%   Source: Reed - What is the simplest way to compute principal curvature 
%                  for a mesh triangle?

%% Input validation is performed by subfunctions.

%% Triangulate faces, if necessary.
if size(faces,2) ~= 3
    faces = triangulateFaces(faces);
end

%% Calculate edges
edges = meshEdges(faces);

%% Calculate edge curvatures.
vertexNormals = vertexNormal(vertices,faces);

nEdges = size(edges,1);
edgeCurvatures = zeros(nEdges,1);

for iEdge = 1:nEdges
    edge = edges(iEdge,:);
    
    vertex1 = vertices(edge(1),:);
    vertex2 = vertices(edge(2),:);
    
    vertexNormal1 = vertexNormals(edge(1),:);
    vertexNormal2 = vertexNormals(edge(2),:);
    
    edgeCurvatures(iEdge) = ...
        dot((vertexNormal2-vertexNormal1),(vertex2-vertex1)) / ...
        sum((vertex2-vertex1).^2);
end

%% Calculate vertex curvatures.
nVertices = size(vertices,1);
vertexCurvatures = zeros(nVertices,1);

for iVertex = 1:nVertices
    edgeIndices = mod(find(edges == iVertex)-1,nEdges)+1;
    vertexCurvatures(iVertex) = geomean(abs(edgeCurvatures(edgeIndices)));
end

end

