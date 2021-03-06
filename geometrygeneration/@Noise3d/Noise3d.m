classdef Noise3d
    %NOISE3D Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        type
        strength = 1
        scale = [1 1 1]
        offset = 0
        lowerClipping = -inf
        upperClipping = inf
        randomSeed = 1
    end
    
    methods
        function obj = Noise3d(type)
            %NOISE3D Construct an instance of this class
            %   Detailed explanation goes here
            
            % Validate type.
            expectedTypes = {
                'uniform'
                'gaussian'
                'simplex'
                };
            
            validatestring(type,expectedTypes);
            
            % Assign attribute.
            obj.type = lower(type);
        end
        
        %% Setters
        function obj = set.scale(obj,value)
            
            if numel(value) == 1
                value = repmat(value,1,3);
            end
            
            % Validate input.
            validateattributes( ...
                value, ...
                {'numeric'}, ...
                {'real','finite','nonnan','nonsparse','nonempty','row','vector','numel',3});
            
            obj.scale = value;
        end
        
        
        %% Others
        
        function amplitudes = getamplitudesforpoints(obj,points)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            
            nPoints = size(points,1);
            
            % Apply scale.
            points = points./obj.scale;
            
            % Store current random seed.
            previousRandomSeed = rng;
            
            % Apply new randomSeed.
            rng(obj.randomSeed);
            
            % Translate points randomly to achieve a randomization of the 
            % simplex noise.
            points = points+rand*10000;
            
            switch obj.type
                case 'uniform'
                    amplitudes = randd([-1 1],nPoints,1);
                case 'gaussian'
                    amplitudes = randn(nPoints,1);
                case 'simplex'
                    amplitudes = zeros(nPoints,1);
                    
                    for iPoint = 1:nPoints
                        point = points(iPoint,:);
                        
                        amplitudes(iPoint) = calculatesimplexamplitude3d(point);
                    end         
            end
            
            % Apply amplitude.
            amplitudes = amplitudes*obj.strength;
                        
            % Apply offset.
            amplitudes = amplitudes+obj.offset;
            
            % Apply clipping.
            amplitudes = clip(amplitudes,obj.lowerClipping,obj.upperClipping);
            
            % Restore random seed.
            rng(previousRandomSeed);
        end
    end
end

