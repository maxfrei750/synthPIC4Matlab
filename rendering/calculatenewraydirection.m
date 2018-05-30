function newRayDirection = calculatenewraydirection(incidentRay,normalVector,indexOfRefraction1,indexOfRefraction2)
%CALCULATENEWRAYDIRECTION calculates the new direction of a reflected or refracted light ray.
% Source: https://www.scratchapixel.com/lessons/3d-basic-rendering/introduction-to-shading/reflection-refraction-fresnel

% Rename variables to keep equations short.
I = normalizeVector3d(incidentRay);
N = normalVector;
etai = indexOfRefraction1;
etat = indexOfRefraction2;

cosi = clip(dot(I,N),-1,1);
n = N;

if cosi < 0
    cosi = -cosi;
else
    [etai,etat] = swap(etai,etat);
    n = -N;
end

eta = etai/etat;
k = 1-eta^2*(1-cosi^2);

if k<0
    % Total internal refraction. Use reflection formular to compute new ray
    % direction.
    newRayDirection = I-2*dot(I,N)*N;
else
    newRayDirection = eta*I+(eta*cosi-sqrt(k))*n;
end

end
