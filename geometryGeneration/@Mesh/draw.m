function hPatch = draw(obj)
% Errorhandling for the color variable is performed by the
% 'patch' class.

% Draw the geometry.
hPatch = drawMesh(obj);

set(hPatch, ...
    fphong, ...
    'FaceVertexCData',obj.texture);

view(3)
daspect([1 1 1])

% If no outputargument was requested, then clear hPatch.
if nargout == 0
    clear hPatch
end
end