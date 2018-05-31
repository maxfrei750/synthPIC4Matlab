function newRayDirections = calculatenewraydirection(incidentRay,normalVector,indexOfRefraction1,indexOfRefraction2)
%CALCULATENEWRAYDIRECTION calculates the new direction of a reflected or refracted light ray.
% Source: https://www.scratchapixel.com/lessons/3d-basic-rendering/introduction-to-shading/reflection-refraction-fresnel



% Rename variables to keep equations short.
I = normalizeVector3d(incidentRay);
N = normalVector;

nRays = size(I,1);

etai = indexOfRefraction1*ones(nRays,1,'gpuArray');
etat = indexOfRefraction2*ones(nRays,1,'gpuArray');

cosi = clip(dot(I,N,2),-1,1);
n = N;

isNegativeCosi = cosi<0;
isNonNegativeCosi = ~isNegativeCosi;

% if cosi >= 0
%     [etai,etat] = swap(etai,etat);
[etai(isNonNegativeCosi),etat(isNonNegativeCosi)] = swap(etai(isNonNegativeCosi),etat(isNonNegativeCosi));
%     n = -N;
n(isNonNegativeCosi) = -N(isNonNegativeCosi);
% else
cosi(isNegativeCosi) = -cosi(isNegativeCosi);
% end

eta = etai./etat;
k = 1-eta.^2.*(1-cosi.^2);

isNegativeK = k<0;
isNonNegativeK = ~isNegativeK;

newRayDirections = zeros(nRays,3,'gpuArray');

% if k<0
%     % Total internal refraction. Use reflection formular to compute new ray
%     % direction.
%     newRayDirections = I-2*dot(I,N)*N;
newRayDirections(isNegativeK,:) = ...
    I(isNegativeK,:) - ...
    2*dot(I(isNegativeK,:),N(isNegativeK,:),2).*N(isNegativeK,:);
% else
%     newRayDirections = eta*I+(eta*cosi-sqrt(k))*n;
newRayDirections(isNonNegativeK,:) = ...
    eta(isNonNegativeK,:).*I(isNonNegativeK,:) + ...
    (eta(isNonNegativeK,:).*cosi(isNonNegativeK,:) - ...
    sqrt(k(isNonNegativeK,:))).*n(isNonNegativeK,:);
% end

newRayDirections = normalizeVector3d(newRayDirections);

end
