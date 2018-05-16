function [collisionPair, indices] = pickcollisionpair(obj)
%PICKCOLLISIONPAIR Randomly pick a collisionpair.
% Source:   Wei; Kruis (2013) - A GPU-based parallelized Monte-Carlo method 
%           for particle coagulation using an acceptance–rejection strategy

collisionProbability = 0;
randomThreshold = 1;

while collisionProbability <= randomThreshold    
    % Select a random collision partner.
    iCollisionPartner1 = randi(obj.nCollisionPartners);
    % Select another random collision partner.
    iCollisionPartner2 = randi(obj.nCollisionPartners);
           
    randomThreshold = rand+eps;
    
    collisionProbability = ...
        obj.normalizedContent(iCollisionPartner1,iCollisionPartner2);
end

% Prepare output parameters.
indices = [iCollisionPartner1 iCollisionPartner2];

collisionPair = [...
    obj.collisionPartnerList(iCollisionPartner1) ...
    obj.collisionPartnerList(iCollisionPartner2)];
    
end