function hPatch = draw(obj,varargin)

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

p.parse(obj,varargin{:});

coloringMode = p.Results.coloringMode;
obj = p.Results.obj;


%% Draw the geometry.
hPatch = drawMesh(obj);

switch lower(coloringMode)
    case 'texture'
        hPatch.FaceVertexCData = obj.texture;
        set(hPatch,fphong) 
    case 'objectid'
        colormap('parula');
        hPatch.FaceVertexCData = obj.facesObjectIDs;
        hPatch.FaceColor = 'flat';
end

if ~islit
     light
end

daspect([1 1 1])
view(3)
material dull

%% If no outputargument was requested, then clear hPatch.
if nargout == 0
    clear hPatch
end
end