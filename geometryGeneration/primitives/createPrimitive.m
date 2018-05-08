function primitive = createPrimitive(type,lengthArray,varargin)
%CREATEPRIMITIVE Summary of this function goes here
%   Detailed explanation goes here

p = inputParser;

expectedTypes_1Length = { ...
    'buckyball', ...
    'cube', ...
    'cubeoctahedron', ...
    'sphere', ...
    'dodecahedron', ...
    'icosahedron', ...
    'octahedron', ...
    'rhombododecahedron', ...
    'tetrahedron', ...
    'tetrakaidecahedron', ...
    };

expectedTypes_2Lengths = { ...
    'cylinder', ...
    'roundedcylinder', ...
    'floor', ...
    };

expectedTypes_2Lengths_nSidesBase = { ...
    % 'pyramid', ...
    % 'bipyramid', ...
    'prism', ...
    };

expectedTypes_3Lengths = { ...
    'cuboid', ...
    'ellipse', ...
    };

expectedTypes_3Lengths_3Angles = { ...
    % 'parallelepiped', ...
    };

expectedTypes = [
    expectedTypes_1Length, ...
    expectedTypes_2Lengths, ...
    expectedTypes_2Lengths_nSidesBase, ...
    expectedTypes_3Lengths, ...
    expectedTypes_3Lengths_3Angles];

isValidType = @(x) any(validatestring(x,expectedTypes));

isValidAngleArray = @(x) validateattributes( ...
    x, ...
    {'numeric'}, ...
    {'real','finite','nonnan','nonsparse','positive','vector','numel',3,'<=',90});

isValidNSidesBase = @(x) validateattributes( ...
    x, ...
    {'numeric'}, ...
    {'real','finite','nonnan','nonsparse','nonempty','positive','scalar','integer'});

p.addRequired('type',isValidType)
p.addRequired('lengthArray');
p.addParameter('angleArray',[],isValidAngleArray);
p.addParameter('nSidesBase',[],isValidNSidesBase);

p.parse(type,lengthArray,varargin{:});

obj.type = lower(p.Results.type);
obj.lengthArray = p.Results.lengthArray;
obj.angleArray = p.Results.angleArray;
obj.nSidesBase = p.Results.nSidesBase;

% Perform validation of lengtharray.
switch obj.type
    case expectedTypes_1Length
        validatelengtharray(lengthArray,1);
    case expectedTypes_2Lengths
        validatelengtharray(lengthArray,2);
    case expectedTypes_2Lengths_nSidesBase
        validatelengtharray(lengthArray,2);
    case expectedTypes_3Lengths
        validatelengtharray(lengthArray,3);
    case expectedTypes_3Lengths_3Angles
        validatelengtharray(lengthArray,3);
        validateanglearray(angleArray,3);
end

% Generate primitive.
switch obj.type
    
    case 'buckyball' % 1 length
        primitive = createSoccerBall;
        primitive.vertices = primitive.vertices*0.5105;
    case 'cube'
        primitive = createCube;
    case 'cubeoctahedron'
        primitive = createCubeOctahedron;
        primitive.vertices = primitive.vertices*0.5;
    case 'dodecahedron'
        primitive = createDodecahedron;
        primitive.vertices = primitive.vertices*0.5;
    case 'icosahedron'
        primitive = createIcosahedron;
        primitive.vertices = primitive.vertices*0.525731112119134;
        primitive.vertices = primitive.vertices-[0 0 0.5];
    case 'octahedron'
        primitive = createOctahedron;
        primitive.vertices = primitive.vertices*0.5;
    case 'rhombododecahedron'
        primitive = createRhombododecahedron;
        primitive.vertices = primitive.vertices*0.25;
    case 'sphere'
        primitive = createIcosphere;
        primitive.vertices = primitive.vertices*0.5;
    case 'tetrahedron'
        primitive = createTetrahedron;
    case 'tetrakaidecahedron'
        primitive = createTetrakaidecahedron;
        primitive.vertices = primitive.vertices*0.25;
        
    case 'cylinder' % 2 lengths
        primitive = createPrism(36,lengthArray(1),lengthArray(2));
    case 'roundedcylinder'
        primitive = createRoundedCylinder(lengthArray(1),lengthArray(2));
    case 'floor'
        primitive = createFloor;
        primitive.vertices = primitive.vertices.*[lengthArray 0];
        
    case 'bipyramid' % 2 lengths, n sides
        % ...
    case 'pyramid'
        % ...
    case 'prism'
        primitive = createPrism(nSidesBase,lengthArray(1),lengthArray(2));
        
    case 'cuboid' % 3 lengths
        primitive = createCube;
    case 'ellipse'
        primitive = createIcosphere;
        primitive.vertices = primitive.vertices*0.5;
    case 'parallelepiped' % 3 lengths, 3 angles
        % ...
end

% If the geometry type belongs to the group of geometries with
% 1 or 3 lengths, simply multiply the vertices with the
% lengtharray. All other cases are already scaled.
switch obj.type
    case [expectedTypes_1Length expectedTypes_3Lengths]
        primitive.vertices = primitive.vertices.*lengthArray;
end

end

