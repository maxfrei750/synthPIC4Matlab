function obj_C = collide(obj_A,obj_B,varargin)
%COLLIDEMESHES Collides two meshes.
%   Collides meshA with meshB.
%
%   Parameters:
%   ===========
%   'speed'       -   Distance that mesh_B moves during each iteration of the
%                     collision simulation.
%                     Default: 10
%
%   'randomness'  -   Degree of randomness of the movement of mesh_B during
%                     the collision. Can have values between 0 (ballistic)
%                     and 1 (pure random walk).
%                     Default: 0
%
%   'sinterratio' -   Amount of sintering to apply. Can have values from 0
%                     (no sintering) to 1 (completely sintered).
%                     Default: 0
%
%   'plot'        -   Defines how to plot the agglomeration. 
%                     Possible values: 'on','off','rotation','rotate'
%                     Default: 'off'


%% Default values
defaultSpeed = 10;
defaultRandomness = 0;
defaultSinterRatio = 0;
defaultPlot = 'off';

%% Parse input parameters.
p = inputParser;

isValidAgglomerate = @(x) isa(x,'Agglomerate');

isValidSpeed = @(x) validateattributes( ...
    x, ...
    {'numeric'}, ...
    {'real','finite','nonnan','nonsparse','nonempty','positive','scalar'});

isValidRandomness = @(x) validateattributes( ...
    x, ...
    {'numeric'}, ...
    {'real','finite','nonnan','nonsparse','nonempty','positive','scalar','>=',0,'<=',1});

isValidSinterRatio = @(x) validateattributes( ...
    x, ...
    {'numeric'}, ...
    {'real','finite','nonnan','nonsparse','nonempty','scalar','>=',0,'<=',1});

isValidPlot = @(x) any(validatestring(x,{'on','off','rotation','rotate'}));

addRequired(p,'obj_A',isValidAgglomerate);
addRequired(p,'obj_B',isValidAgglomerate);
addParameter(p,'speed',defaultSpeed,isValidSpeed);
addParameter(p,'randomness',defaultRandomness,isValidRandomness);
addParameter(p,'plot',defaultPlot,isValidPlot);
addParameter(p,'sinterRatio',defaultSinterRatio,isValidSinterRatio);

parse(p,obj_A,obj_B,varargin{:});

speed = p.Results.speed;
randomness = p.Results.randomness;
sinterRatio = p.Results.sinterRatio;

doRandomWalk = (randomness > 0);
doSinter = (sinterRatio > 0);

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

%% Intialize the collision.
collisionDirection = initializecollision(obj_A,obj_B);

% Set up a bounding box as periodic boundaries.
space = obj_A.boundingBox;
space = space.enlarge(obj_B.boundingBox.dimensions);
space = space.enlarge(-obj_B.boundingBox.dimensions);

% Store original position of obj_B, so it can easily be reset later on.
originalPosition_B = obj_B.centroid;

%% Perform the actual collision.
totalTranslationVector =  zeros(1,3);
doRewind = false;

translationDirection_straight = collisionDirection;
translationDirection = translationDirection_straight;
translationVector = translationDirection*speed;

% Move forward until you collide.
while not(isoverlapping(obj_A,obj_B))
    
    % Reset collsiison and reroll translation direction occasionally to 
    % avoid infinite loops.
    if any(abs(totalTranslationVector)>space.boundingBox.dimensions)
        % Reset the position of obj_B.
        offset = obj_B.centroid-originalPosition_B;
        obj_B = obj_B.translate(-offset);
        
        totalTranslationVector =  zeros(1,3);
        
        % Roll a new translation direction.
        translationDirection_straight = normalizeVector3d(randn(1,3));
        translationDirection = translationDirection_straight;
        translationVector = translationDirection*speed;
    end
    
    % Apply periodic boundaries.
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
    while isoverlapping(obj_A,obj_B);
        % Perform the translation.
        obj_B = obj_B.translate(translationVector);
        totalTranslationVector = totalTranslationVector+translationVector;
    end
end

% Move one step forward, so that you only just touch.
translationVector = -translationVector;
obj_B = obj_B.translate(translationVector);

% Simulate Sintering

% Get overlapping particles
if doSinter
    [~,iPrimaryParticle_A,iPrimaryParticle_B] = isoverlapping(obj_A,obj_B);
    
    primaryParticle_A = obj_A.primaryParticles(iPrimaryParticle_A);
    primaryParticle_B = obj_B.primaryParticles(iPrimaryParticle_B);
    
    sinterVector = ...
        (primaryParticle_A.centroid-primaryParticle_B.centroid)*...
        sinterRatio;
    
    obj_B = obj_B.translate(sinterVector);
end
    
%% Make obj_B a child of obj_A.
obj_C = obj_A.addchild(obj_B);

end
