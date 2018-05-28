classdef RenderScene < handle
    %RENDERSCENE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties       
        tileSize = 128
        relativeResolution = 0.5
    end
    
    properties(SetAccess = private)
        mesh
        imageSize
        
        detectorPosition
        
        %boundingBoxList
        %objectMaskList
    end
    
    properties(Access = private, Hidden = true)
        colorMap
        curvatureMap
        diffuseMap
        objectMap
        binaryObjectMap
        transmissionLengthMap
        incidentAngleMap
        % shadowMap % Yet to be implemented.
    end
    
    
    methods
        %% Constructor
        function obj = RenderScene(mesh,imageSize,detectorPosition)
            %RENDERSCENE Construct an instance of this class
            %   Detailed explanation goes here
            
            % Validate mesh and imageSize.
            validateattributes( ...
                mesh, ...
                {'Mesh'}, ...
                {'nonempty','scalar'});
            
            validateattributes( ...
                imageSize, ...
                {'numeric'}, ...
                {'real','finite','nonnan','nonsparse','nonempty','positive','integer','vector','numel',2});
            
            % Set default value for the detector position (centered above
            % the image, quasi-infinitively far away).
            if nargin<3
                detectorPosition = [imageSize/2 10e4];
            end
            
            % Validate detectorPosition.
            validateattributes( ...
                detectorPosition, ...
                {'numeric'}, ...
                {'real','finite','nonnan','nonsparse','nonempty','row','vector','numel',3});
            
            obj.mesh = mesh;
            obj.imageSize = imageSize;
            obj.detectorPosition = detectorPosition;
        end       
    end
end

