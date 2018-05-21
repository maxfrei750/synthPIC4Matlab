classdef RenderScene < handle
    %RENDERSCENE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        edgeGlowSize = 1
        scanningShadowLength = 100
        transmissionCoefficient = 0.01
        
        tileSize = 128
        relativeResolution = 0.5
    end
    
    properties(SetAccess = private)
        mesh
        imageSize
        
        colorMap
        curvatureMap
        diffuseMap
        objectMap
        binaryObjectMap
        transmissionLengthMap
        % shadowMap %Buggy
        
        detectorPosition
        
        boundingBoxList
        objectMaskList
    end
    
    properties(Dependent = true)
        edgeGlowMap
        scanningShadowMap
        transmissionMap
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
        
        %% Setters
        function set.edgeGlowSize(obj,value)
            validateattributes( ...
                value, ...
                {'numeric'}, ...
                {'real','finite','nonnan','nonsparse','nonempty','scalar','positive'});
            
            obj.edgeGlowSize = value;
        end
        
        function set.scanningShadowLength(obj,value)
            validateattributes( ...
                value, ...
                {'numeric'}, ...
                {'real','finite','nonnan','nonsparse','nonempty','scalar','positive','integer'});
            
            obj.scanningShadowLength = value;
        end
        
        function set.transmissionCoefficient(obj,value)
            validateattributes( ...
                value, ...
                {'numeric'}, ...
                {'real','finite','nonnan','nonsparse','nonempty','scalar','positive'});
            
            obj.transmissionCoefficient = value;
        end
        
        %% Getters
        function objectMap = get.objectMap(obj)
            % Render map if it was not rendered before.
            if isempty(obj.objectMap)
                objectMap = renderobjectmap( ...
                    obj.mesh, ...
                    obj.imageSize(2), ...
                    obj.imageSize(1));
                
                obj.objectMap = objectMap;
            else
                objectMap = obj.objectMap;
            end
        end
        
        function binaryObjectMap = get.binaryObjectMap(obj)
            % Render map if it was not rendered before.
            if isempty(obj.binaryObjectMap)
                binaryObjectMap = obj.objectMap > 0;
                
                obj.binaryObjectMap = binaryObjectMap;
            else
                binaryObjectMap = obj.binaryObjectMap;
            end
        end
        
        function colorMap = get.colorMap(obj)
            % Render map if it was not rendered before.
            if isempty(obj.colorMap)
                colorMap = rendercolormap( ...
                    obj.mesh, ...
                    obj.imageSize(2), ...
                    obj.imageSize(1));
                
                obj.colorMap = colorMap;
            else
                colorMap = obj.colorMap;
            end
        end
        
        function diffuseMap = get.diffuseMap(obj)
            % Render map if it was not rendered before.
            if isempty(obj.diffuseMap)
                diffuseMap = renderdiffusemap( ...
                    obj.mesh, ...
                    obj.imageSize(2), ...
                    obj.imageSize(1), ...
                    obj.detectorPosition);
                
                obj.diffuseMap = diffuseMap;
            else
                diffuseMap = obj.diffuseMap;
            end
        end
        
        function transmissionLengthMap = get.transmissionLengthMap(obj)
            % Render map if it was not rendered before.
            if isempty(obj.transmissionLengthMap)
                transmissionLengthMap = rendertransmissionlengthmap( ...
                    obj.mesh, ...
                    obj.imageSize(2), ...
                    obj.imageSize(1), ...
                    'tileSize',obj.tileSize, ...
                    'relativeResolution',obj.relativeResolution);
                
                obj.transmissionLengthMap = transmissionLengthMap;
            else
                transmissionLengthMap = obj.transmissionLengthMap;
            end
        end
        
        function curvatureMap = get.curvatureMap(obj)
            % Render map if it was not rendered before.
            if isempty(obj.curvatureMap)
                curvatureMap = rendercurvaturemap( ...
                    obj.mesh, ...
                    obj.imageSize(2), ...
                    obj.imageSize(1));
                
                obj.curvatureMap = curvatureMap;
            else
                curvatureMap = obj.curvatureMap;
            end
        end
        
        % % Buggy
        % function shadowMap = get.shadowMap(obj)
        %     % Render map if it was not rendered before.
        %     if isempty(obj.shadowMap)
        %         shadowMap = rendershadowmap( ...
        %             obj.mesh, ...
        %             obj.imageSize(2), ...
        %             obj.imageSize(1), ...
        %             'tileSize',obj.tileSize, ...
        %             'relativeResolution',obj.relativeResolution, ...
        %             'detectorPosition',obj.detectorPosition);
        %
        %         obj.shadowMap = shadowMap;
        %     else
        %         shadowMap = obj.shadowMap;
        %     end
        % end
        
        function edgeGlowMap = get.edgeGlowMap(obj)
            edgeGlowMap = renderedgeglowmap( ...
                obj.diffuseMap, ...
                obj.colorMap, ...
                obj.edgeGlowSize);
        end
        
        function scanningShadowMap = get.scanningShadowMap(obj)
            scanningShadowMap = renderscanningshadowmap( ...
                obj.objectMap, ...
                obj.scanningShadowLength);
        end
        
        function transmissionMap = get.transmissionMap(obj)
            transmissionMap = rendertransmissionmap( ...
                obj.transmissionLengthMap, ...
                obj.transmissionCoefficient);
        end
        
    end
end

