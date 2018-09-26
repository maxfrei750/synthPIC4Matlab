function obj_C = collide(obj_A,obj_B,varargin)
%COLLIDEMESHES Collides two meshes.
%   Collides meshA with meshB.
%
%   Parameters:
%   ===========
%   'speed'     -   Distance that mesh_B moves during each iteration of the
%                   collision simulation.
%                   Default: 10
%
%   'randomness'-   Degree of randomness of the movement of mesh_B during
%                   the collision. Can have values between 0 (ballistic)
%                   and 1 (pure random walk).
%                   Default: 0


%% Default values
defaultSpeed = 10;
defaultRandomness = 0;

%% Parse input parameters.
p = inputParser;

isValidAgglomerate = @(x) isa(x,'Agglomerate');

isValidSpeed = @(x) ...
    isnumeric(x) && ...
    (x > 0) && ...
    isscalar(x);

isValidRandomness = @(x) ...
    isnumeric(x) && (x >= 0) && ...
    (x <= 1) && ...
    isscalar(x);

isValidPlot = @(x) any(validatestring(x,{'on','off','rotation','rotate'}));

addRequired(p,'obj_A',isValidAgglomerate);
addRequired(p,'obj_B',isValidAgglomerate);
addParameter(p,'speed',defaultSpeed,isValidSpeed);
addParameter(p,'randomness',defaultRandomness,isValidRandomness);
addParameter(p,'plot','off',isValidPlot);

parse(p,obj_A,obj_B,varargin{:});

speed = p.Results.speed;
randomness = p.Results.randomness;

doRandomWalk = (randomness > 0);

% Plot options
switch lower(p.Results.plot)
    case 'on'
        doPlot = true;
        doPlotRotation = false;
    case 'off'
        doPlot = false;
        doPlotRotation = false;
    case {'rotation','rotate'}
        doPlot = true;
        doPlotRotation = true;
end

% If meshA is empty then the collided mesh is just mesh_B.
if isempty(obj_A)
    obj_C = obj_B;
    return
end

% Objects cannot be collided with themselves.
if obj_A == obj_B
    error('Objects cannot be collided with themselves.');
end

% if obj_A == obj_B
%     obj_B = copy(obj_A);
% end

%% Intialize the collision.

% % Make copies of obj_A and obj_B.
% obj_A = copy(obj_A);
% obj_B = copy(obj_B);

collisionDirection = initializecollision(obj_A,obj_B);

% Set up a bounding box as periodic boundaries.
space = obj_A.boundingBox;
space = space.enlarge(obj_B.boundingBox.dimensions);
space = space.enlarge(-obj_B.boundingBox.dimensions);

%% Perform the actual collision.
totalTranslationVector =  zeros(1,3);
doRewind = false;

translationDirection_straight = collisionDirection;
translationDirection = translationDirection_straight;
translationVector = translationDirection*speed;

% Move forward until you collide.
while not(isoverlapping(obj_A,obj_B))
    
    obj_B = applyperiodicboundaries(obj_B,space);
    
    if doRandomWalk
        % Create 1x3-vector of doubles ranging from -1 to 1.
        translationDirection_random = randd([-1 1],1,3);
        
        % Normalize the |translationDirection_random|-vector.
        translationDirection_random = ...
            normalizeVector3d(translationDirection_random);
        
        % Superpose straight translation with random translation.
        translationDirection = ...
            (1-randomness)*translationDirection_straight + ...
            randomness*translationDirection_random;
        
        % Normalize translation direction vector.
        translationDirection = normalizeVector3d(translationDirection);
        
        translationVector = translationDirection*speed;
    end
    
    % Perform the translation.
    obj_B = obj_B.translate(translationVector);
    
    % Plot the collision.
    if doPlot
        plotcollision(obj_A,obj_B,doPlotRotation)
        pause(0.1)
    end
    
    totalTranslationVector = totalTranslationVector+translationVector;
    doRewind = true;
end

% Move backward until you do not collide anymore.
if doRewind
    
    translationVector = -normalizeVector3d(translationVector);
    
    % Rewind, until there is no more overlap.
    while isoverlapping(obj_A,obj_B)
        % Perform the translation.
        obj_B = obj_B.translate(translationVector);
        totalTranslationVector = totalTranslationVector+translationVector;
        
    end
end

% Move one step forward, so that you only just touch.
translationVector = -translationVector;
obj_B = obj_B.translate(translationVector);

%% Make obj_B a child of obj_A.
obj_C = obj_A.addchild(obj_B);

end
