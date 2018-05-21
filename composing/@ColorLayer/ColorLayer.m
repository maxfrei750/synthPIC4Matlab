classdef ColorLayer < PixelBasedLayer
    %COLORLAYER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        color = 1
    end
   
    methods
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

