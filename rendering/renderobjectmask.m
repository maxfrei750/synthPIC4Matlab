function objectMask = renderobjectmask(mesh,width,height)
%RENDERDIFFUSEMAP Summary of this function goes here
%   Detailed explanation goes here

%% Set parameters.
% Enable hardware-rendering
opengl hardware

%% Render the geometry.
% Set figure properties.
hFigure = figure;
hFigure.Visible = 'off';
hFigure.Color = [0 0 0];

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
set(hPatch,fphong,'FaceVertexCData',ones(mesh.nVertices,3));

material dull

frame = getframe(hAxis);
objectMask = frame2im(frame);
close(hFigure);

% Remove redundant color channels.
objectMask = objectMask(:,:,1);
objectMask = im2double(objectMask);

% Flip diffuse map.
objectMask = flipud(objectMask);

%% Push data to gpu, if one is available.
if isgpuavailable
    objectMask = gpuArray(objectMask);
end

end

