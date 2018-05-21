function edgeGlowMap = renderedgeglowmap(diffuseMap,colorMap,edgeGlowSize)
%RENDEREDGEGLOWMAP Compute an edgeGlowMap based on a diffusemap.
%   Detailed explanation goes here

%% Validate inputs.
validateattributes( ...
    diffuseMap, ...
    {'numeric','gpuArray'}, ...
    {'real','finite','nonnan','nonsparse','nonempty','ndims',2,'>=',0,'<=',1});

validateattributes( ...
    edgeGlowSize, ...
    {'numeric'}, ...
    {'real','finite','nonnan','nonsparse','nonempty','scalar','positive'});

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

