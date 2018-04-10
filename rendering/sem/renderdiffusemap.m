function diffuseMap = renderdiffusemap(mesh,width,height)
%RENDERDIFFUSEMAP Summary of this function goes here
%   Detailed explanation goes here

%% Set parameters.
detectorPosition = [-1000 -500 3000];

baseColor = ones(1,3)*1;

% Enable hardware-rendering
opengl hardware

%% Render the geometry.
% Set figure properties.
hFigure = figure;
hFigure.Visible = 'off';
hFigure.Color = baseColor;

hFigure.Units = 'normalized';
hFigure.OuterPosition = [0 0 1 1];

hFigure.Units = 'pixels';
hFigure.Position = [0 0 width+1 height+1];

% Set axis properties.
daspect([1 1 1]);
view(2)
hAxis = gca;
hAxis.Visible = 'off';
hAxis.Units = 'pixels';
hAxis.Position = [0 0 width+1 height+1];

hAxis.YLim = [0 height];
hAxis.XLim = [0 width];

% Draw the current geometry.
hPatch = drawMesh(mesh);

% Set patch properties.
hPatch.EdgeColor = 'none';
set(hPatch,fphong,'FaceVertexCData',mesh.texture);

material dull

% Set light properties.
hLight = light;
hLight.Position = detectorPosition;
hLight.Style = 'local';

frame = getframe(hAxis);
diffuseMap = frame2im(frame);
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

