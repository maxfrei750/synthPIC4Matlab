function meshStruct = tostruct(obj)
%TOSTRUCT Returns a struct containing the vertices and faces of the mesh.
meshStruct.vertices = obj.vertices;
meshStruct.faces = obj.faces;
end

