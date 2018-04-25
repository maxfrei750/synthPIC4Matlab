function randomDouble = randd(minMaxArray,n)
%RANDD Generates uniformly distributed random double-values within the 
%limits passed via minMaxArray.
%
%   minMaxArray - Upper and lower limit, in which the random double-values
%                 shall lie.
%   n           - Number of random values to

if nargin < 2
    n = 1;
end

minMaxArray = sort(minMaxArray);

lowerLimit = minMaxArray(1);
upperLimit = minMaxArray(2);

randomDouble = repmat(lowerLimit,n,1)+rand(n,1)*(upperLimit-lowerLimit);
end

