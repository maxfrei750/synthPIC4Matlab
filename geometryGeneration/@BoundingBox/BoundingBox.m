classdef BoundingBox < Mesh
    %BOUNDINGBOX Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        %% Constructor
        function obj = BoundingBox(vertices)
            [vertices,faces,faces_quads] = bounding_box(vertices);
            
            obj@Mesh(vertices,faces);
            
            obj.faces_quads = faces_quads;
        end
    end
end

