function edgeGlowMap = renderedgeglowmap(obj,edgeGlowSize)
%RENDEREDGEGLOWMAP Compute an edgeGlowMap based on a diffusemap and a colormap.

% Set default value for edgeGlowSize.
if nargin<2
    edgeGlowSize = 2;
end

% Validate input.
validateattributes( ...
    edgeGlowSize, ...
    {'numeric'}, ...
    {'real','finite','nonnan','nonsparse','nonempty','scalar','positive'});

%% Render necessary maps.
% Render diffuseMap.
diffuseMap = obj.renderdiffusemap;

% Render colorMap.
colorMap = obj.rendercolormap;

%% Calculate edgeGlowMap
edgeGlowMap = diffuseMap.*colorMap;

edgeGlowMap = imgaussfilt(edgeGlowMap,2);

edgeGlowMap = imfilter(edgeGlowMap,fliplr(fspecial('sobel')'),'symmetric');

edgeGlowMap(edgeGlowMap>0) = edgeGlowMap(edgeGlowMap>0)/max(edgeGlowMap(:));
edgeGlowMap(edgeGlowMap<0) = edgeGlowMap(edgeGlowMap<0)/abs(min(edgeGlowMap(:)*10));

edgeGlowMap = imgaussfilt(edgeGlowMap,edgeGlowSize);

%% Push data to gpu, if one is available.
if isgpuavailable
    edgeGlowMap = gpuArray(edgeGlowMap);
end
end

