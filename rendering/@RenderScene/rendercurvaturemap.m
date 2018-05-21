function curvatureMap = rendercurvaturemap(obj)
%RENDERCURVATUREMAP Summary of this function goes here
%   Detailed explanation goes here

% If map was already rendered, then return the already rendered map.
if ~isempty(obj.curvatureMap)
    curvatureMap = obj.curvatureMap;
    return
end

% Copy mesh.
mesh = obj.mesh;

%% Set parameters.
baseColor = ones(1,3)*0.5;

%% Render the geometry.
% Set figure properties.
hFigure = figure;
hFigure.Visible = 'off';
hFigure.Color = baseColor;

% Get vertex curvatures.
vertexCurvatures = meshVertexCurvature(obj.mesh.vertices,obj.mesh.faces); 

% Normalize vertexCurvatures.
vertexCurvatures(end+1) = 0;
vertexCurvatures = mat2gray(vertexCurvatures);
vertexCurvatures(end) = [];

% Set texture.
mesh.texture = repmat(vertexCurvatures,1,3);

% Draw the current geometry.
hPatch = draw_sem(mesh);

% Set patch properties.
hPatch.EdgeColor = 'none';

% Convert figure to image.
curvatureMap = figure2image(hFigure,obj.imageSize);

% Close figure.
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

%% Assign the associated ...Map-attribute of the object.
obj.curvatureMap = curvatureMap;

end

