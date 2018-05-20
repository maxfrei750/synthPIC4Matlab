function hPatch = draw_sem(obj)

%% Validate inputs

assert(isa(obj,'Mesh'),'Expected input to be an object of class Mesh.');

%% Draw the geometry.
hPatch = drawMesh(obj);


hPatch.FaceVertexCData = obj.texture;
set(hPatch,fphong)


hPatch.LineStyle = 'none';
daspect([1 1 1])
view(2)
material dull

%% If no outputargument was requested, then clear hPatch.
if nargout == 0
    clear hPatch
end
end