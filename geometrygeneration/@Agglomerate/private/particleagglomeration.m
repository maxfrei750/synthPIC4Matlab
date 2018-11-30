function obj = particleagglomeration(obj,particleList,randomness)
%PARTICLEAGGLOMERATION Summary of this function goes here
%   Detailed explanation goes here

% Determine number of particles.
nParticles = numel(particleList);

obj.mesh = particleList(1).mesh;
% Iterate through all particles and collide them one by one.
for iParticle = 2:nParticles
       
    % Select a particle;
    particle = particleList(iParticle);
    
    % Perform the collision.
    obj = obj.collide( ...
        particle, ...
        'randomness',randomness, ...
        'speed',obj.agglomerationSpeed, ...
        'sinterRatio',obj.sinterRatio);
end

end

