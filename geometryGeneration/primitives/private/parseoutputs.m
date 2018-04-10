function varargout = parseoutputs(vertices,faces,edges)
switch nargout
    case {0, 1}
        mesh = Mesh;
        mesh.faces = faces;
        mesh.vertices = vertices;
        varargout{1} = mesh;
    case 2
        varargout{1} = vertices;
        varargout{2} = faces;
    case 3
        varargout{1} = vertices;
        varargout{2} = faces;
        varargout{3} = edges;
    otherwise
        error('Expected 1, 2 or 3 outputs.');
end
end

