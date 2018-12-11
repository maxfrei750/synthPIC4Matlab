function hPatch = draw_sem(obj)

%% Validate inputs

assert(isa(obj,'Mesh'),'Expected input to be an object of class Mesh.');

opengl software

%% Draw the geometry.
hPatch = drawMesh(obj);
hPatch.FaceVertexCData = obj.texture;

% Set properties of the patch object, based on, whether face or point
% colors where specified.
if size(obj.texture,1) == obj.nFaces
    hPatch.FaceColor = 'flat';
else 
    hPatch.FaceColor = 'interp';
end

hPatch.LineStyle = 'none';
daspect([1 1 1])
view(2)
material dull

if ~isunix % Switching to hardware OpenGL rendering at runtime on unix is not supported.
    warning('off','MATLAB:opengl:unableToSelectHWGL');
    opengl hardware
    warning('on','MATLAB:opengl:unableToSelectHWGL');
end

%% If no outputargument was requested, then clear hPatch.
if nargout == 0
    clear hPatch
end
end