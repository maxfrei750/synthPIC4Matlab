function diffuseMap = renderdiffusemap(mesh,width,height,detectorPosition)
%RENDERDIFFUSEMAP Summary of this function goes here
%   Detailed explanation goes here

%% Set parameters.

% Set default value for detectorPosition.
if nargin<4
    detectorPosition = [width/2 height/2 10e4];
end

baseColor = ones(1,3);

%% Render the geometry.
% Set figure properties.
hFigure = figure;
hFigure.Visible = 'off';
hFigure.Color = baseColor;

% Draw the current geometry.
mesh.texture = ones(mesh.nVertices,3);
hPatch = draw_sem(mesh);

% Set patch properties.
hPatch.EdgeColor = 'none';

% Set light properties.
material dull
hLight = light;
hLight.Position = detectorPosition;

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
