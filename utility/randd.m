function X = randd(minMaxArray,varargin)
%RANDD Generates uniformly distributed random double-values within the 
%limits passed via minMaxArray.
%
%   minMaxArray - Upper and lower limit, in which the random double-values
%                 shall lie.

% Validate input.
validateattributes( ...
    minMaxArray, ...
    {'numeric'}, ...
    {'real','finite','nonnan','nonsparse','nonempty','row','vector','numel',2});

X = minMaxArray(1)+rand(varargin{:})*diff(minMaxArray);
end

