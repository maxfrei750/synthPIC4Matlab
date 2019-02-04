function shadowMap = renderscanningshadowmap(obj,scanningShadowLength)
%RENDERSCANNINGSHADOWMAP Renders a shadowmap resulting from charge effects.

% Set default value for scanningShadowLength.
if nargin<2
    scanningShadowLength = 10;
end

% Validate input.
validateattributes( ...
    scanningShadowLength, ...
    {'numeric'}, ...
    {'real','finite','nonnan','nonsparse','nonempty','scalar','positive','integer'});

%% Render necessary maps.
% Render objectMap.
objectMap = obj.renderobjectmap;

%% Generate shadowmap.
% Calculate shadowmap only for shadowOffset_max > 0.
if scanningShadowLength > 0
    
    shadowMaps = cell(scanningShadowLength,1);
    
    for shadowOffset = 1:scanningShadowLength
        % Shift the object map.
        shiftedObjectMask = padarray(objectMap,[0 shadowOffset],0,'pre');
        shiftedObjectMask = shiftedObjectMask(:,1:end-shadowOffset);
        
        % Calculate shifted shadowmap.
        shadowMaps{shadowOffset} = shiftedObjectMask-objectMap;
        shadowMaps{shadowOffset} = clip(shadowMaps{shadowOffset},0,1);
    end
    
    % Average shadowmaps.
    shadowMap = mean(cat(3,shadowMaps{:}),3);
    
    % Invert shadowMap
    shadowMap = 1-shadowMap;
else
    shadowMap = ones(size(objectMap));
end

end

