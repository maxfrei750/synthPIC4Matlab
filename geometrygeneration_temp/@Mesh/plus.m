function obj1 = plus(obj1,obj2)
%Validate obj2.
validateattributes(obj2,{'Mesh'},{'numel',1});

% Check if obj1 is empty.
if isempty(obj1)
    obj1 = obj2;
    return
end

% Check if obj2 is empty.
if isempty(obj2)
    return
end

% Concatenate meshes. Faces MUST be concatenated before vertices.
obj1.faces = ...
    [obj1.faces;obj2.faces+obj1.nVertices];
obj1.nObjects = obj1.nObjects+1;
obj1.facesObjectIDs = ...
    [obj1.facesObjectIDs;obj2.facesObjectIDs+obj1.nObjects];
obj1.texture = [obj1.texture;obj2.texture];
obj1.vertices = [obj1.vertices;obj2.vertices];

end