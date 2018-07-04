function isOverlapping = isoverlapping(obj_A,obj_B)
%ISOVERLAPPING Summary of this function goes here
%   Detailed explanation goes here

subObjectList_A = [obj_A obj_A.getalldescendants];
subObjectList_B = [obj_B obj_B.getalldescendants];

nSubObjects_A = numel(subObjectList_A);
nSubObjects_B = numel(subObjectList_B);

for iSubObject_A = 1:nSubObjects_A
    
    subObject_A = subObjectList_A(iSubObject_A);
    
    for iSubObject_B = 1:nSubObjects_B
        subObject_B = subObjectList_B(iSubObject_B);
        
        isOverlapping = detectmeshcollision(subObject_A.mesh,subObject_B.mesh);
        
        if isOverlapping
            break
        end
    end
    
    if isOverlapping
        break
    end
end
end

