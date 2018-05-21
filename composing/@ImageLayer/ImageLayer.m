classdef ImageLayer < PixelBasedLayer
    %IMAGELAYER Summary of this class goes here
    %   Detailed explanation goes here       
    properties(Hidden = true)
        originalPixelData
    end
    
    methods
        
        %% Constructor
        function obj = ImageLayer(image)
            %IMAGELAYER Construct an instance of this class
            
            % Validate input.
            validateattributes( ...
                image, ...
                {'numeric','gpuArray'}, ...
                {'real','finite','nonnan','nonsparse','nonempty','ndims',2});
            
            % Convert pixelData to double.
            image = im2double(image);
            
            % Assign originalPixelData property.
            obj.originalPixelData = image;
        end
    end
end

