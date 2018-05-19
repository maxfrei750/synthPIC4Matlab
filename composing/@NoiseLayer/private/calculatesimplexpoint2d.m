% Description : Array and textureless GLSL 2D simplex noise function.
%      Author : Ian McEwan, Ashima Arts.
%  Maintainer : stegu
%     Lastmod : 20110822 (ijm)
%     License : Copyright (C) 2011 Ashima Arts. All rights reserved.
%               Distributed under the MIT License. See LICENSE file.
%               https://github.com/ashima/webgl-noise
%               https://github.com/stegu/webgl-noise
%
function noise = calculatesimplexpoint(x,y) % v => 2D

v = [x y];

C = [0.211324865405187  % (3.0-sqrt(3.0))/6.0
    0.366025403784439  % 0.5*(sqrt(3.0)-1.0)
    -0.577350269189626  % -1.0 + 2.0 * C.x
    0.024390243902439]; % 1.0 / 41.0
% First corner
i  = floor(v + dot(v, [C(2) C(2)]));
x0 = v -   i + dot(i, [C(1) C(1)]);

% Other corners
%i1.x = step( x0.y, x0.x ); % x0.x > x0.y ? 1.0 : 0.0
%i1.y = 1.0 - i1.x;

if x0(1)>x0(2)
    i1 = [1 0];
else
    i1 = [0 1];
end

% x0 = x0 - 0.0 + 0.0 * C.xx ;
% x1 = x0 - i1 + 1.0 * C.xx ;
% x2 = x0 - 1.0 + 2.0 * C.xx ;

x12 = [x0 x0] + [C(1) C(1) C(3) C(3)];
x12(1:2) = x12(1:2)-i1;

% Permutations
i = mod289(i); % Avoid truncation effects in permutation
p = permute_custom(permute_custom(i(2) + [0.0, i1(2), 1.0])+ i(1) + [0.0, i1(1), 1.0]);

m = max(0.5-[dot(x0,x0),dot(x12(1:2),x12(1:2)),dot(x12(3:4),x12(3:4))],0.0);
m = m.*m;
m = m.*m;

% Gradients: 41 points uniformly over a line, mapped onto a diamond.
% The ring size 17*17 = 289 is close to a multiple of 41 (41*7 = 287)

x = 2.0 * fract(p * C(4)) - 1.0;
h = abs(x) - 0.5;
ox = floor(x + 0.5);
a0 = x - ox;

% Normalise gradients implicitly by scaling m
% Approximation of: m *= inversesqrt( a0*a0 + h*h );
m = m.*(1.79284291400159 - 0.85373472095314 * ( a0.*a0 + h.*h ));

% Compute final noise value at P
g(1)  = a0(1)  * x0(1)  + h(1)  * x0(2);
g(2:3) = a0(2:3) .* [x12(1) x12(3)] + h(2:3) .* [x12(2) x12(4)];
noise = 130.0 * dot(m, g);

noise = mat2gray(noise);
end


function y = mod289(x)
y = x - floor(x * (1.0 / 289.0)) * 289.0;
end

function y = permute_custom(x)
y = mod289(((x*34.0)+1.0).*x);
end

function y = fract(x)
y = x-floor(x);
end
