function setup
% SETUP Adds all necessary folders to the MATLAB search path.

% Specify necessary folders.
subPathList = {
    fullfile('composing')
    fullfile('datasetgeneration');
    fullfile('external','CommandLineProgressBar')
    fullfile('external','gptoolbox','external')
    fullfile('external','gptoolbox','external','matlabPyrTools')
    fullfile('external','gptoolbox','matrix')
    fullfile('external','gptoolbox','mesh')
    fullfile('external','gptoolbox','mex')
    fullfile('external','Hardware accelerated ray-triangle intersection')
    fullfile('external','matgeom','matGeom','geom3d')
    fullfile('external','matgeom','matGeom','meshes3d')
    fullfile('external','MATLAB-GJK-Collision-Detection')
    fullfile('external','wmean')
    fullfile('external','DataHash')
    fullfile('geometrygeneration')
    fullfile('geometrygeneration','primitives')
    fullfile('rendering')
    fullfile('utility')
    };

% Get root path of synthPIC4Matlab.
rootPath = fileparts(mfilename('fullpath'));

% Create a pathlist.
pathList = fullfile(rootPath,subPathList);

% Add all paths of the pathlist.
for path = pathList'
    addpath(path{:})
end

% Save the paths permanently.
savepath;

end

