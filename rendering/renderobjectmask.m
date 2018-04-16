function objectMask = renderobjectmask(mesh,width,height)
%RENDERDIFFUSEMAP Summary of this function goes here
%   Detailed explanation goes here


%% Render the geometry.
% Set figure properties.
hFigure = figure;
hFigure.Visible = 'off';
hFigure.Color = [1 1 1];

hAxis = axes;
hAxis.Color = [1 1 1];

% Set texture of the mesh to uniform white.
mesh.texture = zeros(mesh.nVertices,3);

% Draw the current geometry.
hPatch = mesh.draw;

% Set patch properties.
hPatch.EdgeColor = 'none';

% Convert figure to image.
objectMask = figure2image(hFigure,width,height);

% Close figure.
close(hFigure);

% Remove redundant color channels.
objectMask = objectMask(:,:,1);
objectMask = im2double(objectMask);

% Flip diffuse map.
objectMask = flipud(objectMask);

% Invert objectmask.
objectMask = imcomplement(objectMask);

%% Push data to gpu, if one is available.
if isgpuavailable
    objectMask = gpuArray(objectMask);
end

end

