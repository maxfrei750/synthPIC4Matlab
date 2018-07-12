function individualObjectMaps = renderindividualobjectmaps(obj)
%RENDERINDIVIDUALOBJECTMAPS Summary of this function goes here
%   Detailed explanation goes here

% If maps were already rendered, then return the already rendered map.
if ~isempty(obj.individualObjectMaps)
    individualObjectMaps = obj.individualObjectMaps;
    return
end

blankFullImageMask = false(obj.imageSize);

nMasks = numel(obj.masks);

individualObjectMaps = cell(nMasks,1);

for iMask = 1:nMasks
    individualObjectMaps{iMask} = insertmask( ...
        blankFullImageMask, ...
        obj.masks{iMask}, ...
        obj.boundingBoxes{iMask});
end

%% Assign the associated ...Map-attribute of the object.
obj.individualObjectMaps = individualObjectMaps;
end

