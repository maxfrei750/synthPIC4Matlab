function obj = clusteragglomeration(obj,agglomerateList,randomness)
%CLUSTERAGGLOMERATION Summary of this function goes here
%   Detailed explanation goes here

nAgglomerates = numel(agglomerateList);
nCollisions = nAgglomerates-1;

%% Create collision matrix.
collisionMatrix = CollisionMatrix(agglomerateList);

%% Perform the collisions
for iCollision = 1:nCollisions
    [collisionPair, collisionPairIndices] = ...
        collisionMatrix.pickcollisionpair;
    
    % Collide the voxelArrays of the two agglomerates and store
    % the resulting voxelArray in agglomerate1.
    collisionPair(1) = collide( ...
        collisionPair(1), ...
        collisionPair(2), ...
        'speed',obj.agglomerationSpeed, ...
        'randomness',randomness, ...
        'plot','off');
    
    %     % Merge fractionlists of the agglomerates and keep only
    %     % unique fractions.
    %     collisionPair(1).fractionList = ...
    %         unique([collisionPair(:).fractionList]);
    %     collisionPair(1).nFractions = numel(collisionPair(1).fractionList);
    
    % Replace the modified first agglomerate in the collisionMatrix.
    collisionMatrix = collisionMatrix.updatecollisionpartner( ...
        collisionPair(1),collisionPairIndices(1));
    
    % Remove the second agglomerate from the collisionMatrix.
    collisionMatrix = ...
        collisionMatrix.removecollisionpartner(collisionPairIndices(2));
    
    % Update the number of agglomerates.
    nAgglomerates = nAgglomerates-1;
end

%% Return the final agglomerate.
obj = collisionMatrix.collisionPartnerList;

end

