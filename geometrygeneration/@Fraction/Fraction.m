classdef Fraction < handle
    %FRACTION Class to represent a particle fraction.
    % Stores the properties of a particle fraction.

    properties
        % Primary-particle type (click for more information).
        %
        %   Types can be grouped according to the number of
        %   parameters needed to define them:
        %   
        %   1 parameter (scale/diameter/sidelength)
        %   'buckyball'
        %   'cube'
        %   'cubeoctahedron'
        %   'sphere'
        %   'dodecahedron'
        %   'icosahedron'
        %   'octahedron'
        %   'rhombododecahedron'
        %   'tetrahedron'
        %   'tetrakaidecahedron'
        %
        %   2 parameters (diameter/sidelength1 and height/sidelength2)        
        %   'cylinder'
        %   'roundedcylinder'
        %   'floor'
        %   
        %   3 parameters (number of base-sides, scale/diameter and height)
        %   'pyramid' (not jet supported)
        %   'bipyramid' (not jet supported)
        %   'prism'
        %   
        %   3 parameters (3 sidelengths/axislengths)
        %   'cuboid'
        %   'ellipsoid'
        %   
        %   6 parameters (3 sidelengths and 3 angles)
        %   'parallelepiped' (not jet supported)
        type
        
        angleDistributionList % List of angle distributions to draw angles from.
        
        lengthDistributionList % List of length distributions to draw lengths from.
        
        nSidesBase % Number of base-sides (if applicable).
        
        smoothingLevel = 0 % Smoothing level of the geometry (default: 0).
        subdivisionLevel = 1 % Subdivision level of the geometry (default: 1).
        
        color = 1 % Color of the primary particles of this fraction (default: 1, range: 0-1).
        
        displacementLayers % Zero or more layers of Displacement (see also 'doc Displacement').
        
        % Absolute proportion of the fraction (default: 1). 
        %   Only relevant, when there are multiple fractions in an agglomerate.
        proportion = 1 
        
        name % Arbitrary name of the fraction.                
        bulkDensity = 1 % In mass/voxel.
    end
    
    methods
        function obj = Fraction(type,lengthDistributionList,varargin)
            %FRACTION Construct an instance of the fraction class.
            
            % Parse input parameters.
            p = inputParser;
            
            isValidDistributionList = @(x) validateattributes( ...
                x, ...
                {'prob.ToolboxParametricDistribution'}, ...
                {'nonempty','row','vector'});
            
            isValidNSidesBase = @(x) validateattributes( ...
                x, ...
                {'numeric'}, ...
                {'real','finite','nonnan','nonsparse','nonempty','scalar','integer','>',2});
            
            addRequired(p,'type'); % Validity is checked in sub-functions.
            addRequired(p,'lengthDistributionList',isValidDistributionList);
            addParameter(p,'angleDistributionList',[],isValidDistributionList);
            addParameter(p,'nSidesBase',[],isValidNSidesBase);
            
            parse(p,type,lengthDistributionList,varargin{:});
            
            obj.type = type;
            obj.lengthDistributionList = lengthDistributionList;
            obj.angleDistributionList = p.Results.angleDistributionList;
            obj.nSidesBase = p.Results.nSidesBase;
        end
    end
end

