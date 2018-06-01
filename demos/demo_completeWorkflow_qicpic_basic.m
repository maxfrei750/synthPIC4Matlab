clear
close all

% Ensure reproducibility.
rng(3); 

%% Generate a mesh of an agglomerate.

% Define agglomerate properties.
primaryParticleType = 'octahedron'; % For other types see 'doc Fraction'.
nPrimaryParticles = 5; % Number of primary particles in the agglomerate.
agglomerationMode = 'DLA'; % Diffusion limited agglomeration (DLA).

% Define a size distribution for the generation of primary particles.
d_g = 100;
s_g = 1.2;

diameterDistribution = makedist( ...
    'lognormal', ...
    'mu',log(d_g), ...
    'sigma',log(s_g));

% Create a particle fraction and define its properties.
fraction = Fraction(primaryParticleType,diameterDistribution);

% Perform the agglomeration by creating an agglomerate-object.
agglomerate = Agglomerate(agglomerationMode,fraction,nPrimaryParticles);

% Retrieve the complete mesh of the agglomerate.
mesh = agglomerate.completeMesh;

% Optional: Plot the mesh.
figure
mesh.draw('objectID'); % 'objectID': Color the individual primary particles.

%% Render the agglomerate.

% Define the parameters of the render scene.
imageSize = [400 600]; %[height(y-axis) width(x-axis)]

% Set indices of refraction.
ior_inside = 1.3;
ior_outside = 1;

% Position the mesh at the center of the image.
mesh = mesh.centerat([imageSize(2)/2 imageSize(1)/2 0]); % [x y z]

% Create a RenderScene-object.
renderScene = RenderScene(mesh,imageSize,'ior_inside',ior_inside,'ior_outside',ior_outside);

% Retrieve the desired render passes (maps).
renderScene.tileSize = 150;
refractionMap = renderScene.renderrefractionmap;

% Optional: Show the retrieved map.
figure
imagesc(refractionMap)
cBar = colorbar;
ylabel(cBar,'Minimum exit angle [°]');

angleThreshold_degree = 10;

intensityMap = refractionMap<=angleThreshold_degree;

figure
imshow(intensityMap)


