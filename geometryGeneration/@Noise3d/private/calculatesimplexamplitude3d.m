% Portation from GSLS

% Description : Array and textureless GLSL 2D/3D/4D simplex 
%               noise functions.
%      Author : Ian McEwan, Ashima Arts.
%  Maintainer : stegu
%     Lastmod : 20110822 (ijm)
%     License : Copyright (C) 2011 Ashima Arts. All rights reserved.
%               Distributed under the MIT License. See LICENSE file.
%               https:%github.com/ashima/webgl-noise
%               https:%github.com/stegu/webgl-noise

function noiseValue = calculatesimplexamplitude3d(point) % v => 3D

v = single(point);
% v = point;

C = [0.166666666666667 0.333333333333333];

D = [0 0.5 1 2];

% First corner
i  = floor(v + dot(v, C([2 2 2])));
x0 = v - i + dot(i, C([1 1 1]));

% Other corners

g = step_glsl(x0([2 3 1]),x0([1 2 3]));
l = 1-g;
i1 = min_glsl(g([1 2 3]), l([3 1 2]));
i2 = max_glsl(g([1 2 3]), l([3 1 2]));

x1 = x0 - i1 + C([1 1 1]);
x2 = x0 - i2 + C([2 2 2]);
x3 = x0 - D([2 2 2]);

% Permutations
i = mod289(i); % Avoid truncation effects in permutation
p = permute_glsl(permute_glsl(permute_glsl( ...
      i(3) + [0, i1(3), i2(3), 1]) ...
    + i(2) + [0, i1(2), i2(2), 1]) ...
    + i(1) + [0, i1(1), i2(1), 1]);

% Gradients: 7x7 points over a square, mapped onto an octahedron.
% The ring size 17*17 = 289 is close to a multiple of 49 (49*6 = 294)

n_ = 0.142857142857; % 1/7

ns = n_ .* D([4 2 3]) - D([1 3 1]);

j = p - 49 .* floor(p .* ns(3) .* ns(3)); % mod(p,7*7);

x_ = floor(j .* ns(3));
y_ = floor(j - 7 .* x_); % mod(j,N)

x = x_ .* ns(1) + ns([2 2 2 2]);
y = y_ .* ns(1) + ns([2 2 2 2]);
h = 1 - abs(x) - abs(y);

b0 = [x([1 2]) y([1 2])];
b1 = [x([3 4]) y([3 4])];

s0 = floor(b0) .* 2 + 1;
s1 = floor(b1) .* 2 + 1;
sh = -step_glsl(h,[0 0 0 0]);

a0 = b0([1 3 2 4]) + s0([1 3 2 4]) .* sh([1 1 2 2]);
a1 = b1([1 3 2 4]) + s1([1 3 2 4]) .* sh([3 3 4 4]);

p0 = [a0([1 2]) h(1)];
p1 = [a0([3 4]) h(2)];
p2 = [a1([1 2]) h(3)];
p3 = [a1([3 4]) h(4)];

% Normalize gradients
norm = taylorInvSqrt([dot(p0,p0) dot(p1,p1) dot(p2,p2) dot(p3,p3)]);

p0 = p0 .* norm(1);
p1 = p1 .* norm(2);
p2 = p2 .* norm(3);
p3 = p3 .* norm(4);

% Mix final noise value
m = max_glsl(0.6 - [dot(x0,x0) dot(x1,x1) dot(x2,x2) dot(x3,x3)], 0);
m = m .* m;

noiseValue = 42 .* dot(m .*m, [dot(p0,x0) dot(p1,x1) dot(p2,x2) dot(p3,x3)]);
end


function y = mod289(x)
y = x - floor(x .* (1/289)) .* 289;
end

function y = permute_glsl(x)
y = mod289(((x .* 34)+1).*x);
end

function y = taylorInvSqrt(r)
  y =  1.79284291400159 - 0.85373472095314 .* r;
end

function z = min_glsl(x,y)
    z = y.*(y<=x)+x.*not(y<=x);
end

function z = max_glsl(x,y)
    z = y.*(y>=x)+x.*not(y>=x);
end

function z = step_glsl(edge,x)
    z = double(x >= edge);
end


