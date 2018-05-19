function obj = apply(obj)
%APPLY Summary of this function goes here
%   Detailed explanation goes here

maskSize = size(obj.mask);

assert( ...
    isequal(maskSize,obj.size), ...
    'Mask size ([%d %d]) does not match image size ([%d %d]).', ...
    maskSize(1), maskSize(2), ...
    obj.size(1), obj.size(2));

switch obj.blendMode
    case {'additive', 'add'}
        % If there is no pixelData to process yet, then create neutral
        % pixelData.
        if isempty(obj.parent.pixelData)
            obj.parent.pixelData = zeros(obj.size);
        end
        
        obj.parent.pixelData(obj.mask) = ...
            obj.parent.pixelData(obj.mask) + ...
            obj.pixelData(obj.mask);
    case {'multiplicative', 'multiply', 'multi'}
        % If there is no pixelData to process yet, then create neutral
        % pixelData.
        if isempty(obj.parent.pixelData)
            obj.parent.pixelData = ones(obj.size);
        end
        
        obj.parent.pixelData(obj.mask) = ...
            obj.parent.pixelData(obj.mask) .* ...
            obj.pixelData(obj.mask);
end

obj.parent.pixelData = clip(obj.parent.pixelData,[0 1]);

end

