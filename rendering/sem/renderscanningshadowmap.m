function shadowMap = rendershadowmap(objectMask,shadowOffset_max)
%RENDERSHADOWMAP Renders a shadowmap resulting from charge effects.

%% Validate inputs.
validateattributes( ...
    objectMask, ...
    {'numeric','gpuArray'}, ...
    {'real','finite','nonnan','nonsparse','nonempty','ndims',2,'>=',0,'<=',1});

validateattributes( ...
    shadowOffset_max, ...
    {'numeric'}, ...
    {'real','finite','nonnan','nonsparse','nonempty','nonnegative','scalar','integer'});

%% Generate shadowmap.
% Calculate shadowmap only for shadowOffset_max > 0.
if shadowOffset_max > 0
    
    shadowMaps = cell(shadowOffset_max,1);
    
    for shadowOffset = 1:shadowOffset_max
        % Shift the object map.
        shiftedObjectMask = padarray(objectMask,[0 shadowOffset],0,'pre');
        shiftedObjectMask = shiftedObjectMask(:,1:end-shadowOffset);
        
        % Calculate shifted shadowmap.
        shadowMaps{shadowOffset} = shiftedObjectMask-objectMask;
        shadowMaps{shadowOffset} = clip(shadowMaps{shadowOffset},0,1);
    end
    
    % Average shadowmaps.
    shadowMap = mean(cat(3,shadowMaps{:}),3);
    
    % Invert shadowMap
    shadowMap = 1-shadowMap;
else
    shadowMap = ones(size(objectMask));
end

%% Push data to gpu, if one is available.
if isgpuavailable
    shadowMap = gpuArray(shadowMap);
end

end

