%% Preparation

clear
close all

% Create a primitive geometry.
geometry = Geometry('sphere',200);

% Subdivide the geometry to have enough points for the displacement.
geometry.subdivisionLevel = 4;

% Show geometry.
figure
geometry.draw;

%% Create and add the first displacement layer:
% a very large displacement to break up the spherical shape
geometry.displacementLayers(1) = Displacement('simplex'); % Simplex noise is continuous
geometry.displacementLayers(1).strength = 20;
geometry.displacementLayers(1).scale = 200;

% Show result.
figure
geometry.draw;

%% Create and add the second displacement layer:
% a smaller noise with plateaus
geometry.displacementLayers(2) = Displacement('simplex'); % Simplex noise is continuous
geometry.displacementLayers(2).strength = 10;
geometry.displacementLayers(2).scale = 50;

geometry.displacementLayers(2).lowerClipping = -3; % the clipping creates the plateaus.
geometry.displacementLayers(2).upperClipping = 3;

% Show result.
figure
geometry.draw;

%% Create and add the third displacement layer:
% a very small noise for a rough surfacetexture.
geometry.displacementLayers(3) = Displacement('gaussian');
geometry.displacementLayers(3).strength = 1;
geometry.displacementLayers(3).scale = 10;

% Show result.
figure
geometry.draw;
