classdef TemGridLayer < PixelBasedLayer
    %TEMGRIDLAYER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        scale = [1 1]
        randomSeed = 0
        nTiles = [5 5];
        relativeHoleSize = 0.5;
        regularity = 0.7;
    end
    
    methods       
        %% Setters        
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
                {'real','finite','nonnan','nonsparse','nonempty','vector','numel',2,'>=',1});
            
            obj.scale = value;
        end
        
        function set.nTiles(obj,value)
            % If a scalar was passed, then assume an euql number of tiles
            % in each direction.
            if numel(value) == 1
                value = [value value];
            end
            
            % Validate input.
            validateattributes( ...
                value, ...
                {'numeric'}, ...
                {'real','finite','nonnan','nonsparse','nonempty','positive','integer','vector','numel',2});
            
            obj.nTiles = value;
        end
        
        function set.regularity(obj,value)           
            % Validate input.
            validateattributes( ...
                value, ...
                {'numeric'}, ...
                {'real','finite','nonnan','nonsparse','nonempty','nonzero','scalar'});
            
            obj.regularity = value;
        end
       
    end
end

