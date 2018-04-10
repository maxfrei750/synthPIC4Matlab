classdef Mesh
    %MESH Class to store mesh information.
    %   Faces are automatically triangulated.
    
    properties
        vertices
        faces
        texture
    end
    
    properties(Dependent = true)
        edges
        nVertices
        nEdges
        nFaces
        centerOfMass
    end
    
    methods
        
        %% Setter-Methods
        function obj = set.vertices(obj,value)
            % Validate the input.
            validateattributes( ...
                value, ...
                {'numeric'}, ...
                {'real','finite','nonnan','nonsparse','nonempty','ncols',3});
            
            % Assign property.
            obj.vertices = value;
        end
        
        function obj = set.texture(obj,value)
            % Validate the input.
            validateattributes( ...
                value, ...
                {'numeric'}, ...
                {'real','finite','nonnan','nonsparse','nonempty','ncols',3});
            
            % Assign property.
            obj.texture = value;
        end
        
        function obj = set.faces(obj,value)
            % Triangulate the faces if necessary.
            if size(value,2) ~= 3
                value = triangulateFaces(value);
            end
            
            % Validate the input.
            validateattributes( ...
                value, ...
                {'numeric'}, ...
                {'real','finite','nonnan','nonsparse','nonempty','positive','2d','ncols',3});
            
            % Assign property.
            obj.faces = value;
            
        end
        
        %% Getter-methods
        function edges = get.edges(obj)
            edges = meshEdges(obj.faces);
        end
        
        function texture = get.texture(obj)
            % If the mesh has no texture, then return a completely white
            % texture.
            if isempty(obj.texture)
                texture = ones(obj.nVertices,3);
            else
                texture = obj.texture;
            end
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
    end
end

