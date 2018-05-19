classdef ImageLayer < PixelBasedLayer
    %IMAGELAYER Summary of this class goes here
    %   Detailed explanation goes here   
    properties(Dependent = true)
        pixelData
    end
    
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
                {'numeric'}, ...
                {'real','finite','nonnan','nonsparse','nonempty','ndims',2});
            
            % Convert pixelData to double.
            image = im2double(image);
            
            % Assign originalPixelData property.
            obj.originalPixelData = image;
        end
        
        %% Getters
        function pixelData = get.pixelData(obj)   
            
            % Adjust brightness of the image.
            pixelData = obj.originalPixelData-0.5+obj.brightness;
            
            % Clip image.
            pixelData = clip(pixelData,[0 1]);
        end
    end
end

