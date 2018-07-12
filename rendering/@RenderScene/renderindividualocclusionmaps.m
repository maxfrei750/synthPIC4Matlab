function individualOcclusionMaps = renderindividualocclusionmaps(obj)
%RENDERINDIVIDUALOCCLUSIONMAPS Summary of this function goes here
%   Detailed explanation goes here

% If maps were already rendered, then return the already rendered map.
if ~isempty(obj.individualOcclusionMaps)
    individualOcclusionMaps = obj.individualOcclusionMaps;
    return
end

% Get complete occlusion map.
completeOcclusionMap = obj.renderocclusionmap;

% Identify unique colors.
colors = unique(completeOcclusionMap);

% Remove black from the list of colors, because that's the background.
colors(colors==0) = [];

% Get number of colors.
nColors = numel(colors);

individualOcclusionMaps = cell(nColors,1);

% Iterate all colors.
for iColor = 1:nColors
    color = colors(iColor);
    individualOcclusionMaps{iColor} = completeOcclusionMap == color;
end

%% Assign the associated ...Map-attribute of the object.
obj.individualOcclusionMaps = individualOcclusionMaps;
end

