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
        
        ior_inside
        ior_outside
        
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
        refractionMap
        % shadowMap % Yet to be implemented.
    end
    
    
    methods
        %% Constructor
        function obj = RenderScene(mesh,imageSize,varargin)
            %RENDERSCENE Construct an instance of this class
            %   Detailed explanation goes here
            
            % Validation functions          
            isValidMesh = @(x) validateattributes( ...
                x, ...
                {'Mesh'}, ...
                {'nonempty','scalar'});
            
            isValidImageSize = @(x) validateattributes( ...
                x, ...
                {'numeric'}, ...
                {'real','finite','nonnan','nonsparse','nonempty','positive','integer','vector','numel',2});
            
            isValidDetectorPosition = @(x) validateattributes( ...
                x, ...
                {'numeric'}, ...
                {'real','finite','nonnan','nonsparse','nonempty','row','vector','numel',3});
            
            isValidIndexOfRefraction = @(x) validateattributes( ...
                x, ...
                {'numeric'}, ...
                {'real','finite','nonnan','nonsparse','nonempty','positive','scalar'});
            
            % Default values
            defaultDetectorPosition = [imageSize/2 10e4];
            defaultIor_inside = 1.3; %IOR of water
            defaultIor_outside = 1; %IOR of air
            
            % Parse inputs.            
            p = inputParser;
            
            p.addRequired('mesh',isValidMesh);
            p.addRequired('imageSize',isValidImageSize);
            p.addParameter('detectorPosition',defaultDetectorPosition,isValidDetectorPosition);
            p.addParameter('ior_inside',defaultIor_inside,isValidIndexOfRefraction);
            p.addParameter('ior_outside',defaultIor_outside,isValidIndexOfRefraction);
            
            p.parse(mesh,imageSize,varargin{:});         
            
            obj.mesh = mesh;
            obj.imageSize = imageSize;
            obj.detectorPosition = p.Results.detectorPosition;
            obj.ior_inside = p.Results.ior_inside;
            obj.ior_outside = p.Results.ior_outside;
        end       
    end
end

