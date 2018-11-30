function [isOverlapping,iPrimaryParticle_A,iPrimaryParticle_B] = ...
    isoverlapping(obj_A,obj_B)
%ISOVERLAPPING Checks if any primary particles of two agglomerates
%intersect.

% Decide if (and which) collision proxy should be used.
% If we have mixed settings, then none>box>sphere.
collisionProxies = {obj_A.collisionProxy obj_B.collisionProxy};

if any(contains(collisionProxies,'sphere'))
    collisionProxy = 'sphere';
end

if any(contains(collisionProxies,'box'))
    collisionProxy = 'box';
end

if any(contains(collisionProxies,'none'))
    collisionProxy = 'none';
end

% Precheck: If the convex hulls of the agglomerates don't
% intersect, then none of their primary particles can intersect.

% The function detectmeshcollision assumes convex hulls anyhow. So we can 
% just use it on the completeMeshes of the agglomerates.
isOverlappingConvexHulls = detectmeshcollision( ...
    obj_A.completeMesh, ...
    obj_B.completeMesh);

if not(isOverlappingConvexHulls)
    isOverlapping = false;
    iPrimaryParticle_A = NaN;
    iPrimaryParticle_B = NaN;
    
    return
end

% If the convex hulls of the agglomerates don't intersect, then we need to
% check all possible pairs of primary particles for intesections.
primaryParticles_A = obj_A.primaryParticles;
primaryParticles_B = obj_B.primaryParticles;

for iPrimaryParticle_A = 1:obj_A.nPrimaryParticles
    
    primaryParticle_A = primaryParticles_A(iPrimaryParticle_A);
    
    for iPrimaryParticle_B = 1:obj_B.nPrimaryParticles
        primaryParticle_B = primaryParticles_B(iPrimaryParticle_B);
        
        switch collisionProxy
            case 'none'
                isOverlapping = detectmeshcollision( ...
                    primaryParticle_A.mesh, ...
                    primaryParticle_B.mesh);
            case 'box'
                isOverlapping = detectboxcollision( ...
                    primaryParticle_A.mesh, ...
                    primaryParticle_B.mesh);
            case 'sphere'
                isOverlapping = detectspherecollision( ...
                    primaryParticle_A.mesh, ...
                    primaryParticle_B.mesh);
            otherwise
                error('Unknown collisionProxy setting: %s',collisionProxy);
        end
        
        if isOverlapping
            break
        end
    end
    
    if isOverlapping
        break
    end
end
end

