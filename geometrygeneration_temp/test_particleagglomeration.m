% clear
close all

rng(3)

% figure
% view(3)
% box on
% axis off
% 
% xlim([-200 200]);
% ylim([-200 200]);
% zlim([-200 200]);
% xticklabels({});
% yticklabels({});
% zticklabels({});

nParticles = 20;

particleList = Agglomerate.empty(nParticles,0);

% Generate particle list.
for iParticle = 1:nParticles
    % Select a particle
    geometry = Geometry('sphere',randi([10 40]));
    
    particleList(iParticle) = Agglomerate;
    particleList(iParticle).mesh = geometry.mesh;
    
end

agglomerate = Agglomerate.empty;

for iParticle = 1:nParticles
    % Select a particle;
    agglomerate = agglomerate.collide(particleList(iParticle),'randomness',0,'speed',10,'plot','off');
    disp(iParticle)
end

agglomerate.draw('objectid')