classdef CollisionMatrix
    %COLLISIONMATRIX Class to calculate, store and modify collision matrix.
    
    properties
        collisionPartnerList
        nCollisionPartners
        radiusOfGyrationList
        massList
        content
        normalizedContent
    end
    
    methods
        function obj = CollisionMatrix(collisionPartnerList)
            %COLLISIONMATRIX Creates an instance of the CollisionMatrix
            % class and calculates collision frequencies for the objects in
            % the agglomerateList.
            
            % Assign list of collisionpartners.
            obj.collisionPartnerList = collisionPartnerList;
            
            % Get number of collisionpartners.
            obj.nCollisionPartners = numel(collisionPartnerList);
            
            % Calculate radius of gyration for each agglomerate.
            obj.radiusOfGyrationList = ...
                [collisionPartnerList.radiusOfGyration];
            
            % Gather mass of each agglomerate.
            obj.massList = [collisionPartnerList.mass];
            
            % Initialize content of the collision matrix.
            obj.content = zeros(obj.nCollisionPartners);
            
            for i = 1:obj.nCollisionPartners
                for j = 1:obj.nCollisionPartners
                    
                    % Don't calculate collision frequencies with yourself
                    % as the collision partner.
                    if i == j
                        continue
                    end
                    
                    % Utilize symmetry of the collisionmatrix.
                    if i > j
                        continue
                    end
                    
                    % Calculate collision frequency.
                    radiusOfGyration_i = obj.radiusOfGyrationList(i);
                    radiusOfGyration_j = obj.radiusOfGyrationList(j);
                    
                    mass_i = obj.massList(i);
                    mass_j = obj.massList(j);
                    
                    collisionFrequency = ...
                        calculatecollisionfrequency( ...
                        radiusOfGyration_i,radiusOfGyration_j, ...
                        mass_i,mass_j);
                    
                    % Collision matrix is symmetric.
                    obj.content(i,j) = collisionFrequency;
                    obj.content(j,i) = collisionFrequency;
                end
            end
            
            % Normalize collisionmatrix.
            obj = obj.normalizecontent;
        end
    end
end

