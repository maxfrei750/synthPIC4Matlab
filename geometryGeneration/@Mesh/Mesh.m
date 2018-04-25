classdef Mesh
    %MESH Class to store mesh information.
    %   Faces are automatically triangulated.
    
    properties
        texture
    end
    
    properties(SetAccess=private)
        vertices
        faces
        nObjects = 0
        facesObjectIDs
    end
    
    properties(Dependent = true)
        edges
        nVertices
        nEdges
        nFaces
        centerOfMass
        vertexNormals
    end
    
    methods
        %% Constructor
        function obj = Mesh(vertices,faces)
            %% Process vertices.
            % Validate vertices.
            validateattributes( ...
                vertices, ...
                {'numeric'}, ...
                {'real','finite','nonnan','nonsparse','nonempty','ncols',3});
            
            obj.vertices = vertices;
            
            %% Process faces.
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
            
            centerOfMass = mean(randomPointsInVolume);
        end
        
        function vertexNormals = get.vertexNormals(obj)
            vertexNormals = meshVertexNormals(obj.vertices,obj.faces);
        end
    end
end

