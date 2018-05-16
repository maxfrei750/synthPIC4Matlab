function s = fbm (height,width)
%FBM Create a FBM noise.
%   Create a square FBM noise with sidelength m.
%   Source: http://nullprogram.com/blog/2007/11/20/

validateattributes(width,{'numeric'},{'integer'});
validateattributes(height,{'numeric'},{'integer'});

maximumSize = max([width height]);
m = round(maximumSize);

s = zeros(m);    % Output image
w = m;           % Width of current layer
i = 0;           % Iterations

while w > 3
    i = i + 1;
    d = interp2(randn(w), i-1, "spline");
    s = s + i * d(1:m, 1:m);
    w = w - ceil(w/2 - 1);
end

% Crop the noise.
s = s(1:height,1:width);

% Normalize the noise.
s = mat2gray(s);
end