clear
close all

rng(2);

%% Parameters
% Geometry parameters
d_g = 100;
s_g = 1.2;

nPrimaryParticles = 3;

agglomerationMode = 'BCCA';

% Image parameters
imageSize = [300 300];

%% Generate geometry.
diameterDistribution = makedist( ...
    'lognormal', ...
    'mu',log(d_g), ...
    'sigma',log(s_g));

fraction = Fraction('sphere',diameterDistribution);
fraction.color = 0.5;

agglomerate = Agglomerate(agglomerationMode,fraction,nPrimaryParticles);

% agglomerate.draw;

%% Create a renderscene.
% Get mesh.
mesh = agglomerate.completeMesh;

% Center mesh at image center.
mesh = mesh.centerat([imageSize/2 0]);

renderScene = RenderScene(mesh,imageSize);
renderScene.tileSize = 256;

transmissionMap = renderScene.rendertransmissionmap;

imshow(transmissionMap);