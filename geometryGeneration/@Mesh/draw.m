function hPatch = draw(obj,coloringMode)

%% Validate inputs
expectedColoringModes = {
    'texture'
    'objectID'
    };

defaultColoringMode = 'texture';

% Validation functions
isValidObj = @(x) isa(obj,'Mesh');

isValidColoringMode = @(x) any(validatestring(x,expectedColoringModes));

p = inputParser;

p.addRequired('obj',isValidObj);
p.addOptional('coloringMode',defaultColoringMode,isValidColoringMode);

p.parse(obj,coloringMode);

coloringMode = p.Results.coloringMode;
obj = p.Results.obj;


%% Draw the geometry.
hPatch = drawMesh(obj);

switch lower(coloringMode)
    case 'texture'
        set(hPatch, ...
            fphong, ...
            'FaceVertexCData',obj.texture);
    case 'objectid'
        colormap('parula');
        hPatch.LineStyle = 'none';
        hPatch.FaceColor = 'flat';
        hPatch.FaceVertexCData = obj.facesObjectIDs;
end


view(3)
daspect([1 1 1])

%% If no outputargument was requested, then clear hPatch.
if nargout == 0
    clear hPatch
end
end