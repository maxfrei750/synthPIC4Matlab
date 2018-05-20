function varargout = createFloor()
%CREATEFLOOR creates a 1x1 floor in the xy-plane.

maxCoordinate = 1;
minCoordinate = 0;

vertices = [ ...
    minCoordinate minCoordinate 0;
    minCoordinate maxCoordinate 0;
    maxCoordinate maxCoordinate 0;
    maxCoordinate minCoordinate 0];

faces = [ ...
    3 2 1; ...
    4 3 1];

edges = [ ...
    1 2; ...
    1 3; ...
    1 4; ...
    2 3; ...
    3 4];

varargout{1:nargout} = parseoutputs(vertices,faces,edges);
end