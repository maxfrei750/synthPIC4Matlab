function diffuseMap = renderdiffusemap(mesh,width,height)
%RENDERDIFFUSEMAP Summary of this function goes here
%   Detailed explanation goes here

%% Set parameters.
detectorPosition = [-1000 -500 3000];

baseColor = ones(1,3)*1;

%% Render the geometry.
% Set figure properties.
hFigure = figure;
hFigure.Visible = 'off';
hFigure.Color = baseColor;

% Draw the current geometry.
hPatch = mesh.draw;

% Set patch properties.
hPatch.EdgeColor = 'none';

% Set light properties.
material dull
hLight = light;
hLight.Position = detectorPosition;
hLight.Style = 'local';

% Convert figure to image.
diffuseMap = figure2image(hFigure,width,height);

% Close figure.
close(hFigure);

% Remove redundant color channels.
diffuseMap = diffuseMap(:,:,1);
diffuseMap = im2double(diffuseMap);

% Flip diffuse map.
diffuseMap = flipud(diffuseMap);

%% Push data to gpu, if one is available.
if isgpuavailable
    diffuseMap = gpuArray(diffuseMap);
end

end

