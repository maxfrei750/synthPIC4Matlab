classdef BlurLayer < handle
    %BLURLAYER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        parent
        strength
    end
    
    methods
        %% Constructor
        function obj = BlurLayer(strength)
            
            if nargin == 0
                return
            end
            
            % Validate input.
            validateattributes( ...
                strength, ...
                {'numeric'}, ...
                {'real','finite','nonnan','nonsparse','nonempty','scalar'});
            
            obj.strength = strength;
        end
        
        %% Setters
        function set.strength(obj,value)
            % Validate input.
            validateattributes( ...
                value, ...
                {'numeric'}, ...
                {'real','finite','nonnan','nonsparse','nonempty','scalar','positive'});
            
            obj.strength = value;
        end
        
    end
end

