function obj = translate(obj,translationvector)
% Translate mesh of the object itself.
obj.mesh = obj.mesh.translate(translationvector);

% Translate meshes of its descendants.
descendants = obj.getalldescendants;
nDescendants = numel(descendants);

for iDescendants = 1:nDescendants
    descendant = descendants(iDescendants);
    descendant.mesh = descendant.mesh.translate(translationvector);
end
end