function vertices = createPolygonVertices(nSides)
%CREATEPOLYGONVERTICES Create vertices of a polygon with nSides sides.

validateattributes( ...
    nSides, ...
    {'numeric'}, ...
    {'real','finite','nonnan','nonsparse','nonempty','integer','scalar','>=',3});

r = 0.5;
t = linspace(0,2*pi,nSides+1);
t(end) = [];

x = r*cos(t);
y = r*sin(t);
z = zeros(1,nSides);

vertices = [x' y' z'];
end

