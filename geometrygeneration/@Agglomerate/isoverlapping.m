function isOverlapping = isoverlapping(obj_A,obj_B)
%ISOVERLAPPING Summary of this function goes here
%   Detailed explanation goes here

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

