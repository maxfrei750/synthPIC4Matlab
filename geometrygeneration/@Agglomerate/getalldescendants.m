function descendants = getalldescendants(obj)
%GETALLDESCENDANTS Summary of this function goes here
%   Detailed explanation goes here

descendants = Agglomerate.empty;

% Iterate all children of the aggloemrate.
for iChild = 1:obj.nChildren
    child = obj.childList(iChild);
    
    % Add child, because it is a descendant itself.
    descendants = [descendants child];
    
    % Add all descendants of the child.
    descendants = [descendants child.getalldescendants];
end

end

