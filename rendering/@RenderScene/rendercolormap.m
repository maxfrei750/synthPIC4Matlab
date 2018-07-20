function colorMap = rendercolormap(obj)
%RENDERCOLORMAP Summary of this function goes here
%   Detailed explanation goes here

% If map was already rendered, then return the already rendered map.
if ~isempty(obj.colorMap)
    colorMap = obj.colorMap;
    return
end

%% Render the geometry.
% Set figure properties.
hFigure = figure;
hFigure.Visible = 'off';
hFigure.Color = obj.backgroundColor;

% Draw the current geometry.
draw_sem(obj.mesh);

% Convert figure to image.

colorMap = figure2image(hFigure,obj.imageSize);

% Close figure.
close(hFigure);

% Remove redundant color channels.
colorMap = colorMap(:,:,1);
colorMap = im2double(colorMap);

% Flip diffuse map.
colorMap = flipud(colorMap);

%% Push data to gpu, if one is available.
if isgpuavailable
    colorMap = gpuArray(colorMap);
end

%% Assign the associated ...Map-attribute of the object.
obj.colorMap = colorMap;
end

