classdef PixelBasedLayer < handle
    %PIXELBASEDLAYER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        parent
        
        blendMode = 'multiplicative'
        
        brightness = 0.5
        
        mask = []
        
        blurStrength = 0
        
        inverted = false
    end
    
    properties(Dependent = true, Abstract=true)
        pixelData
    end
    
    properties(Dependent = true)
        size
    end
    
    methods(Access = protected)
        pixelData = postprocesspixeldata(obj,pixelData)
    end
    
    methods
        %% Setters
        function set.blendMode(obj,value)
            expectedBlendModes = {
                'additive'
                'add'
                'multiplicative'               
                'multiply'
                'substractive'
                'substract'
                };
            
            validatestring(value,expectedBlendModes);
            
            obj.blendMode = lower(value);
        end
        
        function set.brightness(obj,value)
            % Validate input.
            validateattributes( ...
                value, ...
                {'numeric'}, ...
                {'real','finite','nonnan','nonsparse','nonempty','scalar','nonnegative'});
            
            obj.brightness = value;
        end
        
        function set.blurStrength(obj,value)
            % Validate input.
            validateattributes( ...
                value, ...
                {'numeric'}, ...
                {'real','finite','nonnan','nonsparse','nonempty','scalar','positive'});
            
            obj.blurStrength = value;
        end
        
        %% Getters
        function mask = get.mask(obj)
            if isempty(obj.mask)
                mask = true(obj.size);
            else
                mask = obj.mask;
            end
        end
        
        function size = get.size(obj)
            size = obj.parent.size;
        end
    end
end

