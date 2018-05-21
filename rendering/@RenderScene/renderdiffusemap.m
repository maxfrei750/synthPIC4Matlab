function diffuseMap = renderdiffusemap(obj)
%RENDERDIFFUSEMAP Summary of this function goes here
%   Detailed explanation goes here

% If map was already rendered, then return the already rendered map.
if ~isempty(obj.diffuseMap)
    diffuseMap = obj.diffuseMap;
    return
end

% Copy mesh.
mesh = obj.mesh;

%% Set parameters.
baseColor = ones(1,3);

%% Render the geometry.
% Set figure properties.
hFigure = figure;
hFigure.Visible = 'off';
hFigure.Color = baseColor;

% Draw the current geometry.
mesh.texture = ones(mesh.nVertices,3);
draw_sem(mesh);

% Set light properties.
material dull
hLight = light;
hLight.Position = obj.detectorPosition;

% Convert figure to image.
diffuseMap = figure2image(hFigure,obj.imageSize);

% Close figure.
close(hFigure);

% Remove redundant color channels.
diffuseMap = diffuseMap(:,:,1);
diffuseMap = im2double(diffuseMap);

% Flip diffuse map.
diffuseMap = flipud(diffuseMap);

% Push data to gpu, if one is available.
if isgpuavailable
    diffuseMap = gpuArray(diffuseMap);
end

%% Assign the associated ...Map-attribute of the object.
obj.diffuseMap = diffuseMap;

end

