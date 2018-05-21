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
    
    properties(Hidden=true)
        colorMapData
        curvatureMapData
        diffuseMapData
        objectMapData
        binaryObjectMapData
        transmissionLengthMapData
        % shadowMapData %Buggy
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
            if isempty(obj.objectMapData)
                objectMap = renderobjectmap( ...
                    obj.mesh, ...
                    obj.imageSize(2), ...
                    obj.imageSize(1));
                
                obj.objectMapData = objectMap;
            else
                objectMap = obj.objectMapData;
            end
        end
        
        function binaryObjectMap = get.binaryObjectMap(obj)
            % Render map if it was not rendered before.
            if isempty(obj.binaryObjectMapData)
                binaryObjectMap = obj.objectMap > 0;
                             
                obj.binaryObjectMapData = binaryObjectMap;
            else
                binaryObjectMap = obj.binaryObjectMapData;
            end
        end
        
        function colorMap = get.colorMap(obj)
            % Render map if it was not rendered before.
            if isempty(obj.colorMapData)
                colorMap = rendercolormap( ...
                    obj.mesh, ...
                    obj.imageSize(2), ...
                    obj.imageSize(1));
                
                obj.colorMapData = colorMap;
            else
                colorMap = obj.colorMapData;
            end
        end
        
        function diffuseMap = get.diffuseMap(obj)
            % Render map if it was not rendered before.
            if isempty(obj.diffuseMapData)
                diffuseMap = renderdiffusemap( ...
                    obj.mesh, ...
                    obj.imageSize(2), ...
                    obj.imageSize(1), ...
                    obj.detectorPosition);
                
                obj.diffuseMapData = diffuseMap;
            else
                diffuseMap = obj.diffuseMapData;
            end
        end
        
        function transmissionLengthMap = get.transmissionLengthMap(obj)
            % Render map if it was not rendered before.
            if isempty(obj.transmissionLengthMapData)
                transmissionLengthMap = rendertransmissionlengthmap( ...
                    obj.mesh, ...
                    obj.imageSize(2), ...
                    obj.imageSize(1), ...
                    'tileSize',obj.tileSize, ...
                    'relativeResolution',obj.relativeResolution);
                
                obj.transmissionLengthMapData = transmissionLengthMap;
            else
                transmissionLengthMap = obj.transmissionLengthMapData;
            end
        end
        
        function curvatureMap = get.curvatureMap(obj)
            % Render map if it was not rendered before.
            if isempty(obj.curvatureMapData)
                curvatureMap = rendercurvaturemap( ...
                    obj.mesh, ...
                    obj.imageSize(2), ...
                    obj.imageSize(1));
                
                obj.curvatureMapData = curvatureMap;
            else
                curvatureMap = obj.curvatureMapData;
            end
        end
        
        % Buggy
        %         function shadowMap = get.shadowMap(obj)
        %             % Render map if it was not rendered before.
        %             if isempty(obj.shadowMapData)
        %                 shadowMap = rendershadowmap( ...
        %                     obj.mesh, ...
        %                     obj.imageSize(2), ...
        %                     obj.imageSize(1), ...
        %                     'tileSize',obj.tileSize, ...
        %                     'relativeResolution',obj.relativeResolution, ...
        %                     'detectorPosition',obj.detectorPosition);
        %
        %                 obj.shadowMapData = shadowMap;
        %             else
        %                 shadowMap = obj.shadowMapData;
        %             end
        %         end
        
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

