%% Preparations
clear
% close all

% Ensure reproducibility.
rng(3);

%% Generate a mesh of an agglomerate.

% Define agglomerate properties.
nPrimaryParticles = 5; % Number of primary particles in the agglomerate.
agglomerationMode = 'BCCA'; % Diffusion limited agglomeration (DLA).

% Define fraction1.
d_g = 100;
s_g = 1.2;

sizeDistribution= makedist( ...
    'lognormal', ...
    'mu',log(d_g), ...
    'sigma',log(s_g));


fraction = Fraction('cube',sizeDistribution);

% Cubes have very little vertices and faces to work with. Therefore, we
% need to subdivide them.
fraction.subdivisionLevel = 10;

% Apply a little smoothing to break the edges of the cubes.
fraction.smoothingLevel = 1;

% Perform the agglomeration by creating an agglomerate-object.
agglomerate = Agglomerate( ...
    agglomerationMode, ...
    fraction, ...
    nPrimaryParticles, ...
    'sinterRatio', 0.3);

% Retrieve the complete mesh of the agglomerate.
agglomerateMesh = agglomerate.completeMesh;

%% Simulate the sintering.
sinteredMesh = agglomerateMesh.sinter(10);
sinteredMesh = sinteredMesh.smooth(2);

% Display the sintered Mesh
sinteredMesh.draw;

% % Optional: Overlay the sintered mesh with the orginal mesh.
% % Useful to see whether the ground truth that we are going to extract from
% % the original mesh is still accurate.
% h = agglomerateMesh.draw;
% h.FaceColor = 'red';
% h.FaceAlpha = 0.5;



