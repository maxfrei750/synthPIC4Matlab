clear
close all

rng(2);

d_g = 30;
s_g = 1.2;

nPrimaryParticles = 30;

agglomerationMode = 'BPCA';

diameterDistribution = makedist( ...
    'lognormal', ...
    'mu',log(d_g), ...
    'sigma',log(s_g));

fraction = Fraction('sphere',diameterDistribution);

tic;
agglomerate = Agglomerate( ...
    agglomerationMode, ...
    fraction, ...
    nPrimaryParticles, ...
    'collisionDirectionConstraint',[1 1 0]);
toc;

agglomerate.draw;