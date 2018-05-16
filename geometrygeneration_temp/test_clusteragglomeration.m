clear
close all

rng(1)

figure
view(3)
box on
axis off

xlim([-200 200]);
ylim([-200 200]);
zlim([-200 200]);
xticklabels({});
yticklabels({});
zticklabels({});

nAgglomerates = 50;

%% Generate particle list.
agglomerateList = Agglomerate.empty(nAgglomerates,0);

for iParticle = 1:nAgglomerates
    % Select a particle
    geometry = Geometry('dodecahedron',randi([10 40]));
    geometry.rotationAxisDirection = randd([0 1],1,3);
    geometry.rotationAngleDegree = randd([0 360]);
    
    agglomerateList(iParticle) = Agglomerate;
    agglomerateList(iParticle).mesh = geometry.mesh;
    
end

%% Create collision matrix.
collisionMatrix = CollisionMatrix(agglomerateList);

nCollisions = nAgglomerates-1;

%%
for iCollision = 1:nCollisions
    [collisionPair, collisionPairIndices] = ...
        collisionMatrix.pickcollisionpair;
    
    % Collide the voxelArrays of the two agglomerates and store
    % the resulting voxelArray in agglomerate1.
    collisionPair(1) = collide( ...
        collisionPair(1), ...
        collisionPair(2), ...
    'plot','on');%, ...
    % 'speed',obj.speed, ...
    %   'randomness',randomness);
    
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
    disp(iCollision)
end

finalAgglomerate = collisionMatrix.collisionPartnerList;

collisionPair(1).draw('objectid')