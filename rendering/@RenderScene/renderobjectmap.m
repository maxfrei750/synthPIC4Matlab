function objectMap = renderobjectmap(obj)
%RENDEROBJECTMAP Summary of this function goes here
%   Detailed explanation goes here

% If map was already rendered, then return the already rendered map.
if ~isempty(obj.objectMap)
    objectMap = obj.objectMap;
    return
end

% Copy mesh.
mesh = obj.mesh;

%% Render the geometry.
% Set figure properties.
hFigure = figure;
hFigure.Visible = 'off';
hFigure.Color = [1 1 1];

hAxis = axes;
hAxis.Color = [1 1 1];

% Set texture of the mesh to uniform black.
mesh.texture = zeros(mesh.nVertices,3);

% Draw the current geometry.
draw_sem(mesh);

% Convert figure to image.
objectMap = figure2image(hFigure,obj.imageSize);

% Close figure.
close(hFigure);

% Remove redundant color channels.
objectMap = objectMap(:,:,1);
objectMap = im2double(objectMap);

% Flip diffuse map.
objectMap = flipud(objectMap);

% Invert objectmask.
objectMap = imcomplement(objectMap);

%% Assign the associated ...Map-attribute of the object.
obj.objectMap = objectMap;
end

