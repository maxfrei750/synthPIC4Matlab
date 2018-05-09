function particleList = createparticlelist(fractions,nParticles)
%CREATEPARTICLELIST Create a list of all particles.
%   Create a list of all particles, according to the specified
%   Fractions.

% Determine number of fractions.
nFractions = numel(fractions);

% Determine the number of particles of each fraction.
proportionArray = [fractions.proportion];
proportionArray = proportionArray./sum(proportionArray);

nParticlesArray = round(nParticles*proportionArray);

particleList = Agglomerate.empty;

% Iterate the fractions.
for iFraction = 1:nFractions
    nParticles_fraction = nParticlesArray(iFraction);
    
    fraction = fractions(iFraction);
    
    % Create the particles of the current fraction and add them
    % to the particleList.
    for iParticle_fraction = 1:nParticles_fraction
        particleList(end+1) = fraction.generateparticle;
    end
end

% Arrange the elements of the particleList randomly.
particleList = particleList(randperm(nParticles));
end