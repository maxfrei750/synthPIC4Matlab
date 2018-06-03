function setupMIST4Matlab
% SETUPMIST4MATLAB Adds all necessary folders to the MATLAB search path.

% Specify necessary folders.
subPathList = {
    fullfile('composing')
    fullfile('external')
    fullfile('external','gptoolbox','external')
    fullfile('external','gptoolbox','external','matlabPyrTools')
    fullfile('external','gptoolbox','mesh')
    fullfile('external','MATLAB-GJK-Collision-Detection')
    fullfile('external','Hardware accelerated ray-triangle intersection')
    fullfile('external','geom3d','meshes3d')
    fullfile('external','geom3d','geom3d')
    fullfile('geometrygeneration')
    fullfile('geometrygeneration','primitives')
    fullfile('rendering')
    fullfile('utility')
    };

% Get root path of MIST4Matlab.
rootPath = fileparts(mfilename('fullpath'));

% Create a pathlist.
pathList = fullfile(rootPath,subPathList);

% Add all paths of the pathlist.
for path = pathList'
    addpath(path{:})
end

end

