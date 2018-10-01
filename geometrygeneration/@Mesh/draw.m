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
    case 'objectid'
        colormap('parula');
        hPatch.FaceVertexCData = obj.facesObjectIDs;
end

% Set properties of the patch object, based on, whether face or point
% colors where specified.
if size(hPatch.FaceVertexCData,1) == obj.nFaces
    hPatch.FaceColor = 'flat';
else 
    hPatch.FaceColor = 'interp';
    hPatch.FaceLighting = 'phong';
end

hPatch.EdgeColor = 'none';

if ~islit
     light
end

daspect([1 1 1])
%view(3)
material dull

%% If no outputargument was requested, then clear hPatch.
if nargout == 0
    clear hPatch
end
end