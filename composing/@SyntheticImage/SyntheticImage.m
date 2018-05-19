classdef SyntheticImage < handle
    %SYNTHETICIMAGE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Access = public)
        pixelData
        
        boundingBoxArray
        maskArray
        completeMask
    end
    
    properties(SetAccess = private)
        size
        layerList = {}
    end
    
    properties(Dependent = true)
        nLayers
    end
    
    methods
        %% Constructor
        function obj = SyntheticImage(size)
            %SYNTHETICIMAGE Construct an instance of this class
            %   Detailed explanation goes here
            
            % Validate input.
            validateattributes( ...
                size, ...
                {'numeric'}, ...
                {'real','finite','nonnan','nonsparse','nonempty','positive','integer','vector','numel',2});
            
            obj.size = size;
        end
        
        %% Getters
        function nLayers = get.nLayers(obj)
            nLayers = numel(obj.layerList);
        end
    end
end

