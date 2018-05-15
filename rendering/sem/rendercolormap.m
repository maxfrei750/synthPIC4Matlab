function colorMap = rendercolormap(mesh,width,height)
%RENDERDIFFUSEMAP Summary of this function goes here
%   Detailed explanation goes here

%% Set parameters.
baseColor = ones(1,3)*0;

%% Render the geometry.
% Set figure properties.
hFigure = figure;
hFigure.Visible = 'off';
hFigure.Color = baseColor;

% Draw the current geometry.
hPatch = drawforsem(mesh);

% Set patch properties.
hPatch.EdgeColor = 'none';

% Convert figure to image.
colorMap = figure2image(hFigure,width,height);

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

end

