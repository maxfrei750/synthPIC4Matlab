function obj = updatecollisionpartner( ...
    obj,updatedCollisionPartner,iUpdatedCollisionPartner)
%UPDATECOLLISIONPARTNER Update the row and column of a collisionpartner.

% Update collisionPartnerList.
obj.collisionPartnerList(iUpdatedCollisionPartner) = ...
    updatedCollisionPartner;

% Calculate radius of gyration for the updated collision partner.
obj.radiusOfGyrationList(iUpdatedCollisionPartner) = ...
    updatedCollisionPartner.radiusOfGyration;

% Gather mass of the updated collision partner.
obj.massList(iUpdatedCollisionPartner) = updatedCollisionPartner.mass;

for i = 1:obj.nCollisionPartners
    for j = 1:obj.nCollisionPartners
        
        % Only update the elements of the specified collisionpartner.
        if i == iUpdatedCollisionPartner || j == iUpdatedCollisionPartner
            
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
end

% Re-normalize collisionmatrix.
obj = obj.normalizecontent;

end
