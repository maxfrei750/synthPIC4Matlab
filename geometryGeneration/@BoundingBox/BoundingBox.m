classdef BoundingBox < Mesh
    %BOUNDINGBOX Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        faces_quads
    end
    
    properties(Dependent = true)
        dimensions
        diagonalLength
    end
    
    methods
        %% Constructor
        function obj = BoundingBox(vertices)
            [vertices,faces,faces_quads] = bounding_box(vertices);
            
            obj@Mesh(vertices,faces);
            
            obj.faces_quads = faces_quads;
        end
        
        %% Getters
        function dimensions = get.dimensions(obj)
            dimensions = range(obj.vertices);
        end
        
        function diagonalLength = get.diagonalLength(obj)
            diagonalLength = sqrt(sum(obj.dimensions.^2));
        end
    end
end

