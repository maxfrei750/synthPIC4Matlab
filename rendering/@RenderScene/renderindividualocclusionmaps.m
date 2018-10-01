function individualOcclusionMaps = renderindividualocclusionmaps(obj)
%RENDERINDIVIDUALOCCLUSIONMAPS Summary of this function goes here
%   Detailed explanation goes here

% If maps were already rendered, then return the already rendered map.
if ~isempty(obj.individualOcclusionMaps)
    individualOcclusionMaps = obj.individualOcclusionMaps;
    return
end

% Get objectIdMap.
objectIdMap = obj.renderobjectidmap;

% Get visible object IDs.
visibleObjectIDs = obj.visibleObjectIDs;
nMaps = numel(visibleObjectIDs);

individualOcclusionMaps = cell(nMaps,1);

% Iterate all visible ObjectIDs.
for iMap = 1:nMaps
    objectID = visibleObjectIDs(iMap);
    individualOcclusionMaps{iMap} = objectIdMap == objectID;
end

%% Assign the associated ...Map-attribute of the object.
obj.individualOcclusionMaps = individualOcclusionMaps;
end

