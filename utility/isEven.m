function tf = isEven(number)
%ISEVEN Determine, whether elements of an array are even.

% Validate input.
validateattributes( ...
    number, ...
    {'numeric','gpuArray'}, ...
    {'real','finite','nonnan','nonsparse','nonempty','integer'});

tf = logical(mod(number,2));
end

