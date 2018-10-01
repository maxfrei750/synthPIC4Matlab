function isOverlapping = isoverlapping(obj_A,obj_B)
%ISOVERLAPPING Checks if any primary particles of two agglomerates
%intersect.

% Precheck: If the convex hulls of the agglomerates don't
% intersect, then none of their primary particles can intersect.

% The function detectmeshcollision assumes convex hulls anyhow. So we can 
% just use it on the completeMeshes of the agglomerates.
isOverlappingConvexHulls = detectmeshcollision( ...
    obj_A.completeMesh, ...
    obj_B.completeMesh);

if not(isOverlappingConvexHulls)
    isOverlapping = false;
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
        
        isOverlapping = detectmeshcollision( ...
            primaryParticle_A.mesh, ...
            primaryParticle_B.mesh);
        
        if isOverlapping
            break
        end
    end
    
    if isOverlapping
        break
    end
end
end

