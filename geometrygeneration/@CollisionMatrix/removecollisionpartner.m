function obj = removecollisionpartner(obj,iCollisionPartner)
%REMOVECOLLISIONPARTNER Removes entries of a collisionpartner from the 
% CollisionMatrix.

% Remove collision partner from list of collisionpartners.
obj.collisionPartnerList(iCollisionPartner) = [];

% Remove collision partner from the list of radii of gyration.
obj.radiusOfGyrationList(iCollisionPartner) = [];

% Remove collision partner from the list of masses.
obj.massList(iCollisionPartner) = [];

% Remove row and column of the collisionpartner from content of the 
% collision matrix.
obj.content(iCollisionPartner,:) = [];
obj.content(:,iCollisionPartner) = [];

% Update number of collision partners.
obj.nCollisionPartners = obj.nCollisionPartners-1;

% Re-normalize collisionmatrix.
obj = obj.normalizecontent;
end