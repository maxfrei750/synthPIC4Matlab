classdef BoundingBox < Mesh
    %BOUNDINGBOX Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        %% Constructor
        function obj = BoundingBox(vertices)
            [vertices,triangles,quads] = bounding_box(vertices);
            
            obj@Mesh(vertices,triangles);
            
            obj.faces = quads;
        end
    end
end

