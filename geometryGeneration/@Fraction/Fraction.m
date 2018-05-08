classdef Fraction < handle
    %FRACTION Class to represent a particle fraction.
    %   Stores the properties of a particle fraction.
    
    properties
        type
        
        angleDistributionList
        lengthDistributionList
        nSidesBase
        
        smoothingLevel = 0
        subdivisionLevel = 1
        
        color = 1
        
        displacement
        
        proportion = 1
        name
        bulkDensity = 1     % in mass/voxel
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

