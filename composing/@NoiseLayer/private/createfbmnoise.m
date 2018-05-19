function noise = createfbmnoise(size)
%FBM Create a FBM noise.
%   Source: http://nullprogram.com/blog/2007/11/20/

% Validate input.
validateattributes( ...
    size, ...
    {'numeric'}, ...
    {'real','finite','nonnan','nonsparse','nonempty','positive','integer','vector','numel',2});

maximumSize = max(size);
m = round(maximumSize);

noise = zeros(m);    % Output image
w = m;           % Width of current layer
i = 0;           % Iterations

while w > 3
    i = i + 1;
    d = interp2(randn(w), i-1, "spline");
    noise = noise + i * d(1:m, 1:m);
    w = w - ceil(w/2 - 1);
end

% Crop the noise.
noise = noise(1:size(1),1:size(2));

noise = mat2gray(noise)-0.5;
end