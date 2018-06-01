function subMesh = extractsubmesh(obj,relevantFaceObjectID)
%EXTRACTSUBMESH Summary of this function goes here
%   Detailed explanation goes here

% Validate input.
validateattributes( ...
    relevantFaceObjectID, ...
    {'numeric'}, ...
    {'real','finite','nonnan','nonsparse','nonempty','scalar','positive','integer','<=',obj.nObjects});

% Get relevant faces.
relevantFaces = obj.faces(obj.facesObjectIDs==relevantFaceObjectID,:);

% Get relevant vertices.
relevantVertexIndices = unique(relevantFaces(:));
relevantVertices = obj.vertices(relevantVertexIndices,:);

% Get relevant texture values.
isFaceBasedTexture = size(obj.texture,1) == obj.nFaces;
isVertexBasedTexture = size(obj.texture,1) == obj.nVertices;

if isFaceBasedTexture
    relevantTextureValues = obj.texture(obj.facesObjectIDs==relevantFaceObjectID,:);
elseif isVertexBasedTexture
    relevantTextureValues = obj.texture(relevantVertexIndices,:);
end

% Correct face values.
relevantFaces = relevantFaces-min(relevantFaces(:))+1;

subMesh = Mesh(relevantVertices,relevantFaces);
subMesh.texture = relevantTextureValues;

end

