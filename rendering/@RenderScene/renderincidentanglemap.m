function incidentAngleMap = renderincidentanglemap(obj)
%RENDERCURVATUREMAP Summary of this function goes here
%   Detailed explanation goes here

% If map was already rendered, then return the already rendered map.
if ~isempty(obj.incidentAngleMap)
    incidentAngleMap = obj.incidentAngleMap;
    return
end

% Copy mesh.
mesh = obj.mesh;

%% Set parameters.
baseColor = zeros(1,3);

%% Render the geometry.
% Set figure properties.
hFigure = figure;
hFigure.Visible = 'off';
hFigure.Color = baseColor;

% Get face normals.
faceNormals = meshFaceNormals(mesh.vertices,mesh.faces);
% faceNormals = meshVertexNormals(mesh.vertices,mesh.faces);

% Calculate incident angles. 
% Source: Papula (2009) - Mathematische Formelsammlung: Für Ingenieure und Naturwissenschaftler
% (see also https://en.wikipedia.org/wiki/Dot_product#Geometric_definition)
incidentAngles = faceNormals(:,3);

% Normalize incidentAngles.
incidentAngles(end+1) = 0;
incidentAngles(end+1) = 1;
incidentAngles = mat2gray(incidentAngles);
incidentAngles(end-1:end) = [];

% Set texture.
mesh.texture = repmat(incidentAngles,1,3);

% Draw the current geometry.
hPatch = draw_sem(mesh);

% Set patch properties.
hPatch.EdgeColor = 'none';

% Convert figure to image.
incidentAngleMap = figure2image(hFigure,obj.imageSize);

% Close figure.
close(hFigure);

% Remove redundant color channels.
incidentAngleMap = incidentAngleMap(:,:,1);
incidentAngleMap = im2double(incidentAngleMap);

% Flip diffusivity map.
incidentAngleMap = flipud(incidentAngleMap);

% % % Blur image.
% % incidentAngleMap = medfilt2(incidentAngleMap,[10 10]);
% incidentAngleMap = imgaussfilt(incidentAngleMap,1);
% incidentAngleMap = incidentAngleMap.*obj.renderbinaryobjectmap;
% incidentAngleMap(~obj.renderbinaryobjectmap) = 0;


%% Push data to gpu, if one is available.
if isgpuavailable
    incidentAngleMap = gpuArray(incidentAngleMap);
end

%% Assign the associated ...Map-attribute of the object.
obj.incidentAngleMap = incidentAngleMap;

end

