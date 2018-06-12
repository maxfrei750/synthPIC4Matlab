clear
close all

% Ensure reproducibility.
rng(1); 

%% Generate a mesh of an agglomerate.

% Define agglomerate properties.
primaryParticleType = 'octahedron'; % For other types see 'doc Fraction'.
nPrimaryParticles = 3; % Number of primary particles in the agglomerate.
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
imageSize = flip(ceil(mesh.boundingBox2d(3:4))); %[height(y-axis) width(x-axis)]

% Set indices of refraction.
ior_inside = 1.3;
ior_outside = 1;

% Position the mesh at the center of the image.
mesh = mesh.centerat([mesh.boundingBox2d(3:4)/2 0]); % [x y z]
%mesh = mesh.centerat([0 0 0]); % [x y z]

% Create a RenderScene-object.
renderScene = RenderScene(mesh,imageSize,'ior_inside',ior_inside,'ior_outside',ior_outside);

% Retrieve the desired render passes (maps).
renderScene.tileSize = 150;
refractionMap = renderScene.renderrefractionmap;

% Optional: Filter the refractionMap.
filterSize = 3;
filterKernel = ones(filterSize)/(filterSize^2);
refractionMap = conv2(refractionMap,filterKernel,'same');

% Optional: Show the retrieved map.
figure
imagesc(refractionMap)
cBar = colorbar;
ylabel(cBar,'Minimum exit angle [°]');

angleThreshold_degree = 15;

intensityMap = refractionMap<=angleThreshold_degree;

figure
imshow(intensityMap)


