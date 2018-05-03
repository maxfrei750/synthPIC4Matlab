classdef Agglomerate < handle%matlab.mixin.Copyable
    %AGGLOMERATE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        mesh
        childList = Agglomerate.empty;
        nChildren = 1
        bulkDensity = 1;
        agglomerationMode
        fractions
    end
    
    properties(Dependent=true)
        boundingBox
        completeMesh
        centroid
        mass
        volume
        radiusOfGyration
        centerOfMass
    end

    methods
        function obj = Agglomerate()
            %AGGLOMERATE Construct an instance of this class
            %   Detailed explanation goes here
            obj.childList(1) = obj;
        end
        
        %% Getter methods.
        function completeMesh = get.completeMesh(obj)
            
            completeMesh = Mesh.empty;
            
            for iChild = 1:obj.nChildren
                child = obj.childList(iChild);
                completeMesh = completeMesh+child.mesh;
            end
        end
        
        function boundingBox = get.boundingBox(obj)
            boundingBox = obj.completeMesh.boundingBox;
        end
        
        function centroid = get.centroid(obj)
            centroid = obj.completeMesh.centroid;
        end
        
        function volume = get.volume(obj)           
            volume = meshVolume( ...
                obj.completeMesh.vertices, ...
                [], ...
                obj.completeMesh.faces);
        end
        
        function mass = get.mass(obj)           
            volumes = [obj.childList.volume];
            bulkDensities = [obj.childList.bulkDensity];
            mass = sum(volumes.*bulkDensities);
        end
        
        function centerOfMass = get.centerOfMass(obj)
            centerOfMass = calculatecenterofmass(obj);
        end
        
        function radiusOfGyration = get.radiusOfGyration(obj)
            radiusOfGyration = calculateradiusofgyration(obj);
        end       
        
    end
end

