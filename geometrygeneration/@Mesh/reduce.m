function obj = reduce(obj,varargin)
%REDUCE reduces the number of vertices and faces in a mesh.
%   Basically a wrapper for the built-in function reducepatch. The texture
%   of the mesh object is lost during reduction.

[obj.faces,obj.vertices] = reducepatch(obj.faces,obj.vertices,varargin{:});

% Set texture to white.
obj.texture = ones(obj.nVertices,3);
end

