classdef GradientLayer < PixelBasedLayer
    %GRADIENTLAYER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties        
        angleDegree = 0
        steepness = 1
    end
    
    methods       
        %% Setters
        function set.angleDegree(obj,value)
            % Validate input.
            validateattributes( ...
                value, ...
                {'numeric'}, ...
                {'real','finite','nonnan','nonsparse','nonempty','scalar'});
            
            obj.angleDegree = lower(value);
        end
        
        function set.steepness(obj,value)
            % Validate input.
            validateattributes( ...
                value, ...
                {'numeric'}, ...
                {'real','finite','nonnan','nonsparse','nonempty','scalar'});
            
            obj.steepness = value;
        end
    end
end

