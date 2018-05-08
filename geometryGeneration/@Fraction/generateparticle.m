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

geometry = Geometry(obj.type,lengthArray,varargin{:});
geometry.smoothingLevel = obj.smoothingLevel;
geometry.subdivisionLevel = obj.subdivisionLevel;
geometry.color = obj.color;

% Rotate geometry randomly.
geometry.rotationAxisDirection = randd([0 1],1,3);
geometry.rotationAngleDegree = randd([0 360]);

particle = Agglomerate;
particle.mesh = geometry.mesh;
particle.bulkDensity = obj.bulkDensity;
particle.fractions = obj;
end