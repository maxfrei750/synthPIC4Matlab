function obj1 = plus(obj1,obj2)
%Validate obj2.
validateattributes(obj2,{'Mesh'},{'numel',1});

% Adjust faces of obj2.
nVertices_obj1 = size(obj1.vertices,1);
obj2.faces = obj2.faces+nVertices_obj1;

% Concatenate meshes.
obj1.texture = [obj1.texture;obj2.texture];
obj1.vertices = [obj1.vertices;obj2.vertices];
obj1.faces = [obj1.faces;obj2.faces];
end