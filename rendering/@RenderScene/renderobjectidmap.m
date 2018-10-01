function objectIdMap = renderobjectidmap(obj)
%RENDEROBJECTIDMAP Summary of this function goes here
%   Detailed explanation goes here

% If map was already rendered, then return the already rendered map.
if ~isempty(obj.objectIdMap)
    objectIdMap = obj.objectIdMap;
    return
end

% Copy mesh.
mesh = obj.mesh;

%% Render the geometry.
% Deactivate anti-aliasing
opengl software

% Set figure properties.
hFigure = figure;
hFigure.Visible = 'off';
hFigure.Color = [1 1 1];

hAxis = axes;
hAxis.Color = [1 1 1];

% Draw the current geometry.
hPatch = draw(mesh,'objectID');
hPatch.EdgeColor = 'none';
hPatch.FaceColor = 'flat';
hPatch.FaceLighting = 'none';

% assert(mesh.nObjects

customColorMap = repmat(254:-1:(255-mesh.nObjects),3,1)'./255;
colormap(customColorMap);

% Convert figure to image.
objectIdMap = figure2image(hFigure,obj.imageSize);

% Close figure.
close(hFigure);

% Reactivate anti-aliasing
warning('off','MATLAB:opengl:unableToSelectHWGL');
opengl hardware
warning('on','MATLAB:opengl:unableToSelectHWGL');

% Remove redundant color channels.
objectIdMap = objectIdMap(:,:,1);
objectIdMap = im2double(objectIdMap);

% Flip diffuse map.
objectIdMap = flipud(objectIdMap);

% Invert objectmask.
objectIdMap = imcomplement(objectIdMap);

% Convert objectIdMap to whole numbers.
objectIdMap = round(objectIdMap*255);

%% Push data to gpu, if one is available.
if isgpuavailable
    objectIdMap = gpuArray(objectIdMap);
end

%% Assign the associated ...Map-attribute of the object.
obj.objectIdMap = objectIdMap;
end

