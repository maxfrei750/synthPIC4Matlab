classdef ColorLayer < PixelBasedLayer
    %COLORLAYER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        color = 1
    end
    
    properties(Dependent = true)
        pixelData
    end
    
    methods
        %% Getters
        function pixelData = get.pixelData(obj)
            pixelData = ones(obj.parent.size)*obj.color;
        end
        
        %% Setters
        function obj = set.color(obj,value)
            % Validate input.
            validateattributes( ...
                value, ...
                {'numeric'}, ...
                {'real','finite','nonnan','nonsparse','nonempty','scalar','>=',0,'<=',1});
            
            obj.color = value;
        end
        
        
    end
end

