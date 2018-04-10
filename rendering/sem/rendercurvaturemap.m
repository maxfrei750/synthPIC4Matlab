function curvatureMap = rendercurvaturemap(mesh,width,height)
%RENDERCURVATUREMAP Summary of this function goes here
%   Detailed explanation goes here

%% Set parameters.
baseColor = ones(1,3)*0.5;

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

vertices = mesh.vertices;
faces = mesh.faces;

% Get vertex curvatures.
vertexCurvatures = meshVertexCurvature(vertices,faces); 

% Normalize vertexCurvatures.
vertexCurvatures(end+1) = 0;
vertexCurvatures = mat2gray(vertexCurvatures);
vertexCurvatures(end) = [];

% Draw the current geometry.
hPatch = drawMesh(vertices,faces);

% Set patch properties.
hPatch.EdgeColor = 'none';

set(hPatch, ...
    fphong, ...
    'FaceVertexCData',repmat(vertexCurvatures,1,3));

%% Convert figure to image.
frame = getframe(hAxis);
curvatureMap = frame2im(frame);
close(hFigure);

% Remove redundant color channels.
curvatureMap = curvatureMap(:,:,1);
curvatureMap = im2double(curvatureMap);

% Flip diffusivity map.
curvatureMap = flipud(curvatureMap);

%% Push data to gpu, if one is available.
if isgpuavailable
    curvatureMap = gpuArray(curvatureMap);
end

end

