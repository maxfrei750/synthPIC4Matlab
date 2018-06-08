classdef PixelBasedLayer < handle
    %PIXELBASEDLAYER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        parent
        blendMode = 'multiplicative'
        mask = []
        
        brightness = 0.5
        strength = 1
        blurStrength = 0
        inverted = false
        clipping = [-inf inf]
    end
    
    properties(Dependent = true)
        pixelData
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
                'subtractive'
                'subtract'
                'overlay'
                'replace'
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
        
        function set.clipping(obj,value)
            % Validate input.
            validateattributes( ...
                value, ...
                {'numeric'}, ...
                {'real','finite','nonnan','nonsparse','nonempty','vector','increasing'});
            
            obj.clipping = value;
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
        
        function pixelData = get.pixelData(obj)    
            % Compute pixelData.
            pixelData = computepixeldata(obj);
            
            % Postprocess pixelData (clipping, inversion, blur, etc.).
            pixelData = postprocesspixeldata(obj,pixelData);
        end
    end
end

