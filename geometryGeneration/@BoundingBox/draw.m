function hPatch = draw(obj,faceColor)

if nargin<2
    faceColor = rand(1,3);
end

%% Draw the geometry.
hPatch = drawMesh(obj);

hPatch.FaceAlpha = 0.2;

hPatch.FaceColor = faceColor;

view(3)
daspect([1 1 1])

%% If no outputargument was requested, then clear hPatch.
if nargout == 0
    clear hPatch
end
end