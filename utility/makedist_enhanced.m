function pd = makedist_enhanced(distnameOrConstant,varargin)
%MAKEDIST_ENHANCED Summary of this function goes here
%   Detailed explanation goes here

% Check if the input is a valid constant. Else call the original makedist
% function. All other possible errors are handled there.
isValidConstant = @(x) validateattributes( ...
    x, ...
    {'numeric'}, ...
    {'real','finite','nonnan','nonsparse','nonempty','scalar'});

try 
    isValidConstant(distnameOrConstant);
    
    constant = distnameOrConstant;
    
    % Make a normal distribution with mu = constant and sigma = 0.
    pd = makedist( ...
        'normal', ...
        'mu', constant, ...
        'sigma', 0);
catch
    distname = distnameOrConstant;
    pd = makedist(distname,varargin{:});
end

end

