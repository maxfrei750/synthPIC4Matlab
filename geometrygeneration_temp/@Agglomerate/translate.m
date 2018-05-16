function obj = translate(obj,translationvector)
% Translate each child.
for iChild = 1:obj.nChildren
    child = obj.childList(iChild);
    child.mesh = child.mesh.translate(translationvector);
end
end