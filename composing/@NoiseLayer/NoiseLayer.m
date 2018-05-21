classdef NoiseLayer < PixelBasedLayer
    %NOISELAYER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        type = 'gaussian'
        
        scale = [1 1]
        
        randomSeed = 0
    end
    
    methods       
        %% Setters
        function set.type(obj,value)
            expectedTypes = {
                'uniform'
                'gaussian'
                'simplex'
                'fbm'
                };
            
            validatestring(value,expectedTypes);
            
            obj.type = lower(value);
        end
        
        function set.randomSeed(obj,value)
            % Validate input.
            validateattributes( ...
                value, ...
                {'numeric'}, ...
                {'real','finite','nonnan','nonsparse','nonempty','scalar','positive','integer'});
            
            obj.randomSeed = value;
        end
        
        function set.scale(obj,value)
            
            % If a scalar was passed, then assume a uniform scale.
            if numel(value) == 1
                value = [value value];
            end
            
            % Validate input.
            validateattributes( ...
                value, ...
                {'numeric'}, ...
                {'real','finite','nonnan','nonsparse','nonempty','positive','vector','numel',2});
            
            obj.scale = value;
        end
       
    end
end

