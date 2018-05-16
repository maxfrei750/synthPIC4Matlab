function obj = normalizecontent(obj)
%NORMALIZECONTENT Calculates the a normalzied version of the collisionmatrix.

obj.normalizedContent = obj.content/max(obj.content(:));
end