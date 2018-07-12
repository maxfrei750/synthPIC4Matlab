function occlusionMap = renderocclusionmap(obj)
%RENDEROCCLUSIONMAP Summary of this function goes here
%   Detailed explanation goes here

% If map was already rendered, then return the already rendered map.
if ~isempty(obj.occlusionMap)
    occlusionMap = obj.occlusionMap;
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

customColorMap = gray(mesh.nObjects+1);
customColorMap(end,:) = [];

colormap(customColorMap);

% Convert figure to image.
occlusionMap = figure2image(hFigure,obj.imageSize);

% Close figure.
close(hFigure);

% Reactivate anti-aliasing
opengl hardware

% Remove redundant color channels.
occlusionMap = occlusionMap(:,:,1);
occlusionMap = im2double(occlusionMap);

% Flip diffuse map.
occlusionMap = flipud(occlusionMap);

% Invert objectmask.
occlusionMap = imcomplement(occlusionMap);

%% Push data to gpu, if one is available.
if isgpuavailable
    occlusionMap = gpuArray(occlusionMap);
end

%% Assign the associated ...Map-attribute of the object.
obj.objectMap = occlusionMap;
end

