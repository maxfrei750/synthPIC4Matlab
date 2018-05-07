function obj = enlarge(obj,enlargementVector)
%ENLARGE enlarges a boundingbox.
%   Positive enlargement values are applied in the positive direction and 
%   negative enlargement values are applied in the negative direction.

% Validate input.
validateattributes( ...
    enlargementVector, ...
    {'numeric'}, ...
    {'real','finite','nonnan','nonsparse','nonempty','row','vector','numel',3});

% Iterate the coordinates.
for iColumn = 1:3
    
    if enlargementVector(iColumn) < 0
        isRelevantVertex = obj.vertices(:,iColumn) == min(obj.vertices(:,iColumn));
    elseif enlargementVector(iColumn) > 0
        isRelevantVertex = obj.vertices(:,iColumn) == max(obj.vertices(:,iColumn));
    else 
        continue
    end

    obj.vertices(isRelevantVertex,iColumn) = ...
        obj.vertices(isRelevantVertex,iColumn)+enlargementVector(iColumn);

end
end

