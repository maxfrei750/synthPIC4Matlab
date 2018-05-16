clear
close all

rng(1);

d_g = 10;
s_g = 1.2;

nPrimaryParticles = 10;

agglomerationMode = 'BCCA';

diameterDistribution = makedist( ...
    'lognormal', ...
    'mu',log(d_g), ...
    'sigma',log(s_g));

fraction = Fraction('sphere',diameterDistribution);

fraction.subdivisionLevel = 1;

fraction.displacementLayers = Displacement('simplex'); % Simplex noise is continuous
fraction.displacementLayers.strength = 1;
fraction.displacementLayers.scale = 20;


agglomerate = Agglomerate(agglomerationMode,fraction,nPrimaryParticles);

agglomerate.draw;