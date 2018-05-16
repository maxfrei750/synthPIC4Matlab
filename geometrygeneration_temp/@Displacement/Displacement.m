classdef Displacement < Noise3d
    %DISPLACEMENT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function obj = Displacement(type)
            %DISPLACEMENT Construct an instance of this class
            %   Detailed explanation goes here
            
            obj = obj@Noise3d(type);
        end
        
        function mesh = applyto(obj,mesh)
            mesh = mesh.displace(obj);
        end
    end
    
end

