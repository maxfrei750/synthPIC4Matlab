classdef Agglomerate < handle%matlab.mixin.Copyable
    %AGGLOMERATE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        mesh
        %         collisionPartnerList = Agglomerate.empty;
        childList = Agglomerate.empty;
        nChildren = 1
        %         nCollisionPartners = 0
    end
    
    properties(Dependent=true)
        boundingBox
        completeMesh
        centroid
    end
    
%     methods(Access=protected)
%         function copiedObject = copyElement(obj)
%             copiedObject = copyElement@matlab.mixin.Copyable(obj);
%             
%             
%             
%             for iChild = 2:obj.nChildren
%                 copiedObject.childList(iChild) = copy(obj.childList(iChild));
%             end
%         end
%     end
    
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
        
        %         function nCollisionPartners = get.nCollisionPartners(obj)
        %             nCollisionPartners = numel(obj.CollisionPartnerList);
        %         end
        
        
    end
end

