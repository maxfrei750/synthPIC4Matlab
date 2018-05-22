classdef Geometry < handle
    %GEOMETRY Summary of this class goes here
    %   Detailed explanation goes here
    
    %% Properties
    properties(Dependent = true, SetAccess = protected)
        mesh
    end
    
    properties(Access = public)
        position = [0 0 0]
        subdivisionLevel = 1
        rotationAxisDirection = [1 0 0]
        rotationAngleDegree = 0
        smoothingLevel = 0
        color = 1;
        displacementLayers = Displacement.empty
    end
    
    properties(Access = private)
        primitiveMesh
    end
    
    properties(SetAccess = private)
        type
        lengthArray = []
        angleArray = []
        nSidesBase = [];
    end
    
    %% Methods
    methods
        %% Constructor
        function obj = Geometry(type,lengthArray,varargin)
            %GEOMETRY Construct an instance of the Geometry class.
            
            % Create the primitive.
            primitive = createPrimitive(type,lengthArray,varargin{:});
                       
            % Backup the mesh of the primitive.
            obj.primitiveMesh = Mesh(primitive.vertices,primitive.faces);
            
            % Basic input parsing to assign properties. Detailed parsing 
            % and error handling is done in the createPrimitive function.
            p = inputParser;
            
            p.addRequired('type')
            p.addRequired('lengthArray');
            p.addParameter('angleArray',[]);
            p.addParameter('nSidesBase',[]);
            
            p.parse(type,lengthArray,varargin{:});
            
            obj.type = lower(p.Results.type);
            obj.lengthArray = p.Results.lengthArray;
            obj.angleArray = p.Results.angleArray;
            obj.nSidesBase = p.Results.nSidesBase;       
        end
        
        %% Getter methods
        function meshObject = get.mesh(obj)
            
            % Start with the mesh of the primitive.
            meshObject = obj.primitiveMesh;
            
            % Apply rotation.
            % Disable rotation for spheres.
            if strcmp(obj.type,'sphere')
                warning('Rotation has no effect on ''sphere''-objects.');
            else
                meshObject = meshObject.rotatearoundaxis( ...
                    obj.rotationAxisDirection, ...
                    obj.rotationAngleDegree);
            end
            
            % Apply translation.
            meshObject = meshObject.translate(obj.position);
            
            % Apply subdivision.
            meshObject = meshObject.subdivide(obj.subdivisionLevel);
            
            % Apply smoothing
            % Disable smoothing for spheres.
            if strcmp(obj.type,'sphere')
                warning('SmoothingLevel has no effect on ''sphere''-objects.');
            else
                meshObject = meshObject.smooth(obj.smoothingLevel);
            end
            
            % Apply displacement.
            if ~isempty(obj.displacementLayers)
                for displacementLayer = obj.displacementLayers
                    meshObject = displacementLayer.applyto(meshObject);
                end
            end
            
            % Set texture of the meshObject.
            meshObject.texture = ones(meshObject.nVertices,3)*obj.color;
        end
        
        %% Setter methods
        function set.position(obj,value)
            validateattributes( ...
                value, ...
                {'numeric'}, ...
                {'real','finite','nonnan','nonsparse','nonempty','row','numel',3});
            
            obj.position = value;
        end
        
        function set.subdivisionLevel(obj,value)
            validateattributes( ...
                value, ...
                {'numeric'}, ...
                {'real','finite','nonnan','nonsparse','nonempty','scalar','positive','integer'});
            
            obj.subdivisionLevel = value;
        end
        
        function set.smoothingLevel(obj,value)
            validateattributes( ...
                value, ...
                {'numeric'}, ...
                {'real','finite','nonnan','nonsparse','nonempty','scalar','nonnegative','integer'});
            
            obj.smoothingLevel = value;
        end
        
        function set.rotationAxisDirection(obj,value)
            validateattributes( ...
                value, ...
                {'numeric'}, ...
                {'real','finite','nonnan','nonsparse','nonempty','row','numel',3});
            
            obj.rotationAxisDirection = value;
        end
        
        function set.rotationAngleDegree(obj,value)
            validateattributes( ...
                value, ...
                {'numeric'}, ...
                {'real','finite','nonnan','nonsparse','nonempty','scalar'});
            
            obj.rotationAngleDegree = value;
        end
        
        function set.color(obj,value)
            validateattributes( ...
                value, ...
                {'numeric'}, ...
                {'real','finite','nonnan','nonsparse','nonempty','scalar','>=',0,'<=',1});
            
            obj.color = value;
        end
    end
end

