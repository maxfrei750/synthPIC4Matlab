function obj = translate(obj,translationvector)

particles = obj.primaryParticles;

for iParticle = 1:obj.nPrimaryParticles
    particle = particles(iParticle);
    particle.mesh = particle.mesh.translate(translationvector);
end
end