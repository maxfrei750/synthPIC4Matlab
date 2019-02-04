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

%% Calculate incidentAngles and set texture.
% Get face normals.
faceNormals = mesh.faceNormals;

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

%% Get incidentanglemaps of all objects.
incidentAngleMap = ones(obj.imageSize);

for iObject = 1:mesh.nObjects
    % Get subMesh.
    subMesh = mesh.extractsubmesh(iObject);

    % Set figure properties.
    hFigure = figure;
    hFigure.Visible = 'off';
    hFigure.Color = baseColor;
    
    % Draw the current geometry.
    hPatch = draw_sem(subMesh);
    
    % Set patch properties.
    hPatch.EdgeColor = 'none';
    
    % Convert figure to image.
    currentIncidentAngleMap = figure2image(hFigure,obj.imageSize);
    
    % Close figure.
    close(hFigure);
    
    % Remove redundant color channels.
    currentIncidentAngleMap = currentIncidentAngleMap(:,:,1);
    currentIncidentAngleMap = im2double(currentIncidentAngleMap);
    
    % Flip diffusivity map.
    currentIncidentAngleMap = flipud(currentIncidentAngleMap);
    
    % Replace relevant parts of the incidentAngleMap.
    doReplace = currentIncidentAngleMap <= incidentAngleMap;
    incidentAngleMap(doReplace) = ...
        currentIncidentAngleMap(doReplace);
    
    % % Blur image.
    % incidentAngleMap = medfilt2(incidentAngleMap,[10 10]);
    incidentAngleMap = imgaussfilt(incidentAngleMap,1);
%     incidentAngleMap = incidentAngleMap.*obj.renderbinaryobjectmap;
     incidentAngleMap(~obj.renderbinaryobjectmap) = 1;
end

%% Assign the associated ...Map-attribute of the object.
obj.incidentAngleMap = incidentAngleMap;

end

