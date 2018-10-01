function particle = generateparticle(obj)
lengthArray =  arrayfun(@random,obj.lengthDistributionList);

varargin = {};

if ~isempty(obj.angleDistributionList)
    angleArray = arrayfun(@random,obj.angleDistributionList);
    varargin{end+1} = 'angleArray';
    varargin{end+1} = angleArray;
end

if ~isempty(obj.nSidesBase)
    varargin{end+1} = 'nSidesBase';
    varargin{end+1} = obj.nSidesBase;
end

% Create geometry and copy properties.
geometry = Geometry(obj.type,lengthArray,varargin{:});
geometry.smoothingLevel = obj.smoothingLevel;
geometry.subdivisionLevel = obj.subdivisionLevel;
geometry.color = obj.color;

geometry.displacementLayers = obj.displacementLayers;

% Randomize displacementLayers, if there are any.
if ~isempty(obj.displacementLayers)
    geometry.displacementLayers(:).randomSeed = randi([1 1000]);
end

% Rotate geometry randomly.
geometry.rotationAxisDirection = normalizeVector3d(randn(1,3));
geometry.rotationAngleDegree = randd([0 360]);

particle = Agglomerate;
particle.mesh = geometry.mesh;
particle.bulkDensity = obj.bulkDensity;
particle.fractions = obj;
end