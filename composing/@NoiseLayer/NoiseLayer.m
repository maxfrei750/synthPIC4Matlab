classdef NoiseLayer < PixelBasedLayer
    %NOISELAYER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        type = 'gaussian'
        
        scale = [1 1]
        strength = 1
        
        clipping = [-inf inf]
        
        randomSeed = 0
    end
    
    properties(Dependent = true)
        pixelData
    end
    
    methods
        %% Getters
        function noise = get.pixelData(obj)
            % Store current random seed.
            previousRandomSeed = rng;
            
            % Apply new randomSeed.
            rng(obj.randomSeed);
            
            % Noise size
            noiseSize = round(obj.size ./ obj.scale);
            
            switch obj.type
                case 'uniform'
                    noise = randd([-1 1],noiseSize);
                case 'gaussian'
                    noise = randn(noiseSize);
                case 'fbm'
                    noise = createfbmnoise(noiseSize);
                case 'simplex'
                    noise = createsimplexnoise(obj.size,obj.scale);
            end
            
            % Apply scale.
            noise = imresize(noise,obj.size);
            
            % Apply strength.
            noise = noise*obj.strength;
            
            % Apply brightness.
            noise = noise+obj.brightness;
            
            % Apply clipping.
            noise = clip(noise,obj.clipping);
            
            % Restore random seed.
            rng(previousRandomSeed);
            
            % Apply blur.
            if obj.blurStrength > 0
                noise = imgaussfilt(noise,obj.blurStrength);
            end
        end
        
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
        
        function set.clipping(obj,value)
            % Validate input.
            validateattributes( ...
                value, ...
                {'numeric'}, ...
                {'real','finite','nonnan','nonsparse','nonempty','vector','increasing','>=',0,'<=',1});
            
            obj.clipping = value;
        end
    end
end

