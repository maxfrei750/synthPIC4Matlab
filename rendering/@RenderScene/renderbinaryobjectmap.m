function binaryObjectMap = renderbinaryobjectmap(obj)
%RENDERBINARYOBJECTMAP Summary of this function goes here

% If map was already rendered, then return the already rendered map.
if ~isempty(obj.binaryObjectMap)
    binaryObjectMap = obj.binaryObjectMap;
    return
end

% Retrieve objectMap.
objectMap = obj.renderobjectmap;

% Binarize objectMap.
binaryObjectMap = objectMap > 0;

%% Assign the associated ...Map-attribute of the object.
obj.binaryObjectMap = binaryObjectMap;
end

