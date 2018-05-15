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
displacement1 = Displacement('simplex'); % Simplex noise is continuous
displacement1.strength = 20;
displacement1.scale = 200;

geometry.adddisplacementlayer(displacement1);

% Show result.
figure
geometry.draw;

%% Create and add the second displacement layer:
% a smaller noise with plateaus
displacement2 = Displacement('simplex'); % Simplex noise is continuous
displacement2.strength = 10;
displacement2.scale = 50;

displacement2.lowerClipping = -3; % the clipping creates the plateaus.
displacement2.upperClipping = 3;

geometry.adddisplacementlayer(displacement2);

% Show result.
figure
geometry.draw;

%% Create and add the third displacement layer:
% a very small noise for a rough surfacetexture.
displacement3 = Displacement('gaussian');
displacement3.strength = 1;
displacement3.scale = 10;

geometry.adddisplacementlayer(displacement3);

% Show result.
figure
geometry.draw;
