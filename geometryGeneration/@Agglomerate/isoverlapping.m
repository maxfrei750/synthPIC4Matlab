function isOverlapping = isoverlapping(obj_A,obj_B)
%ISOVERLAPPING Summary of this function goes here
%   Detailed explanation goes here

for iChild_A = 1:obj_A.nChildren
    
    child_A = obj_A.childList(iChild_A);
    
    for iChild_B = 1:obj_B.nChildren
        child_B = obj_B.childList(iChild_B);
        
        isOverlapping = detectmeshcollision(child_A.mesh,child_B.mesh);
        
        if isOverlapping
            break
        end
    end
    
    if isOverlapping
        break
    end
end
end

