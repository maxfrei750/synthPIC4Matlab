classdef Mesh
    %MESH Class to store mesh information.
    %   Faces are automatically triangulated.
    
    properties
        texture
    end
    
    properties(SetAccess=private)
        nObjects = 0
        facesObjectIDs
    end
    
    properties(SetAccess=protected)
        faces
        vertices
    end
    
    properties(Dependent = true)
        edges
        
        nVertices
        nEdges
        nFaces
        
        centerOfMass
        centroid
        
        vertexNormals
        faceNormals
        
        boundingBox
        
        XData
        YData
        ZData
    end
    
    methods
        %% Constructor
        function obj = Mesh(vertices,faces)
            
            if nargin == 0
                obj = Mesh.empty;
            end
            
            %% Process vertices.
            % Validate vertices.
            validateattributes( ...
                vertices, ...
                {'numeric'}, ...
                {'real','finite','nonnan','nonsparse','nonempty','ncols',3});
            
            obj.vertices = vertices;
            
            %% Process faces.
            
            % If no faces were specified, then assume the convex hull.
            if nargin == 1
                faces = convhull( ...
                    vertices(:,1), ...
                    vertices(:,2), ...
                    vertices(:,3));
            end
            
            % Triangulate faces if necessary.
            if size(faces,2) ~= 3
                faces = triangulateFaces(faces);
            end
            
            % Validate faces.
            validateattributes( ...
                faces, ...
                {'numeric'}, ...
                {'real','finite','nonnan','nonsparse','nonempty','positive','2d','ncols',3});
            
            % Check if faces and vertices are compatible.
            assert( ...
                isequal(unique(faces(:))',1:obj.nVertices), ...
                'Values in faces must lie within the range, 1 and number of vertices.');
            
            obj.faces = faces;
            
            %% Set facesObjectIds
            obj.facesObjectIDs = ones(obj.nFaces,1);
            
            %% Set a base texture.
            obj.texture = ones(obj.nVertices,3);
            
        end
        
        %% Setter-methods
        function obj = set.texture(obj,value)
            % Validate the input.
            validateattributes( ...
                value, ...
                {'numeric'}, ...
                {'real','finite','nonnan','nonsparse','nonempty','ncols',3});
            
            % Assign property.
            obj.texture = value;
        end
        
        %% Getter-methods
        function edges = get.edges(obj)
            edges = meshEdges(obj.faces);
        end
        
        function nVertices = get.nVertices(obj)
            nVertices = size(obj.vertices,1);
        end
        
        function nFaces = get.nFaces(obj)
            nFaces = size(obj.faces,1);
        end
        
        function nEdges = get.nEdges(obj)
            nEdges = size(obj.edges,1);
        end
        
        function centerOfMass = get.centerOfMass(obj)
            nRandomPointsInVolume = 10000;
            
            randomPointsInVolume = ...
                getrandompointsinmesh(obj,nRandomPointsInVolume);
            
%             % Plot the random points.
%             scatter3( ...
%                 randomPointsInVolume(:,1), ...
%                 randomPointsInVolume(:,2), ...
%                 randomPointsInVolume(:,3));
            
            centerOfMass = mean(randomPointsInVolume);
        end
        
        function centroid = get.centroid(obj)           
            centroid = mean(obj.vertices);
        end
        
        function vertexNormals = get.vertexNormals(obj)
            vertexNormals = meshVertexNormals(obj.vertices,obj.faces);
        end
        
        function faceNormals = get.faceNormals(obj)
            faceNormals = meshFaceNormals(obj.vertices,obj.faces);
        end
        
        function boundingBox = get.boundingBox(obj)
            boundingBox = BoundingBox(obj.vertices);
        end
        
        function XData = get.XData(obj)
            XData = obj.vertices(:,1);
        end
        
        function YData = get.YData(obj)
            YData = obj.vertices(:,2);
        end
        
        function ZData = get.ZData(obj)
            ZData = obj.vertices(:,3);
        end
    end
end
