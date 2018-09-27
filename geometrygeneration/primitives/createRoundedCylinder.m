function varargout = createRoundedCylinder(diameter,height)
%CREATEROUNDEDCYLINDER Creates a cylinder with round semispherical caps.

[vertices,faces] = createIcosphere(3);

vertices = vertices*diameter*0.5;

if height>diameter
    offset = height-diameter/2;
    vertices(vertices(:,1)>0) = vertices(vertices(:,1)>0)+offset;
    vertices(vertices(:,1)<0) = vertices(vertices(:,1)<0)-offset;
end

%% Assign outputs
switch nargout
    case {0, 1}
        mesh = Mesh(vertices,faces);
        varargout{1} = mesh;
    case 2
        varargout{1} = vertices;
        varargout{2} = faces;
    case 3
        varargout{1} = vertices;
        varargout{2} = faces;
        varargout{3} = meshEdges(faces);
    otherwise
        error('Expected 1, 2 or 3 outputs.');
end

end

