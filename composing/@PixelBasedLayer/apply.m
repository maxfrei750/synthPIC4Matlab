function obj = apply(obj)
%APPLY Summary of this function goes here
%   Detailed explanation goes here

maskSize = size(obj.mask);

assert( ...
    isequal(maskSize,obj.size), ...
    'Mask size ([%d %d]) does not match image size ([%d %d]).', ...
    maskSize(1), maskSize(2), ...
    obj.size(1), obj.size(2));

% If there is no pixelData to process yet, then create neutral
% pixelData, i.e. zeros for additive and ones for multiplicative and
% substractive.
if isempty(obj.parent.pixelData)
    switch obj.blendMode
        case {'additive', 'add'}
            obj.parent.pixelData = zeros(obj.size);
        case {'subtractive', 'subtract', 'multiplicative', 'multiply'}
            obj.parent.pixelData = ones(obj.size);
    end
    
    % Use GPU, if available.
    obj.parent.pixelData = gpuArray(obj.parent.pixelData);
end

switch obj.blendMode
    case {'additive', 'add'}       
        obj.parent.pixelData(obj.mask) = ...
            obj.parent.pixelData(obj.mask) + ...
            obj.pixelData(obj.mask);
    case {'subtractive', 'subtract'}       
        obj.parent.pixelData(obj.mask) = ...
            obj.parent.pixelData(obj.mask) - ...
            obj.pixelData(obj.mask);
    case {'multiplicative', 'multiply'}       
        obj.parent.pixelData(obj.mask) = ...
            obj.parent.pixelData(obj.mask) .* ...
            obj.pixelData(obj.mask);
end

obj.parent.pixelData = clip(obj.parent.pixelData,[0 1]);

end

