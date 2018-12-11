function [collisionDirection,obj_B] = initializecollision(obj_A,obj_B,collisionDirectionConstraint)
%INITIALIZECOLLISION initializes the collision.

%% Stitch the bounding boxes of obj_A and obj_B together
% Select a random facenormal of the boundingBox_A for the stitching.
boundingBoxStitchingFaceNormal_A = getrandomboundingboxface(obj_A);

% Reroll boundingBoxStitchingFaceNormal_A as long as it would be
% impossible to collide due to the collisionDirectionConstraint.
while not(any(boundingBoxStitchingFaceNormal_A & collisionDirectionConstraint))
    boundingBoxStitchingFaceNormal_A = getrandomboundingboxface(obj_A);
end

% The stitching-faceNormal of obj_B is antiparallel to the
% stitching-faceNormal of obj_A.
boundingBoxStitchingFaceNormal_B = -boundingBoxStitchingFaceNormal_A;

% Select a random point on the relevant faces of the bounding boxes of
% obj_A and obj_B.
stitchingPoint_A = getrandompointonboundingboxface( ...
    obj_A, ...
    boundingBoxStitchingFaceNormal_A);

stitchingPoint_B = getrandompointonboundingboxface( ...
    obj_B, ...
    boundingBoxStitchingFaceNormal_B);

% Check if any of the collisionDirections is constraint
doConstrain = (collisionDirectionConstraint == 0);

if any(doConstrain)
    % Calculate the center points of the relevant faces of the bounding
    % boxes of obj_A and obj_B.
    faceCentroid_A = ...
        getboundingboxfacecentroid(obj_A,boundingBoxStitchingFaceNormal_A);
    faceCentroid_B = ...
        getboundingboxfacecentroid(obj_B,boundingBoxStitchingFaceNormal_B);
    
    % Replace indices which are constraint.
    stitchingPoint_A(doConstrain) = faceCentroid_A(doConstrain);
    stitchingPoint_B(doConstrain) = faceCentroid_B(doConstrain);
end

% Calculate the translation vector.
translationVector = stitchingPoint_A-stitchingPoint_B;

% Translate mesh_B so that the random points are aligned.
obj_B = obj_B.translate(translationVector);

%% Calculate collision direction.

% Use a random direction as collision direction.
collisionDirection = normalizeVector3d(randn(1,3));

% %% Visualisation
% randomPoint_A = randomPoint_A_0;
% randomPoint_B = randomPoint_B_0+translationVector;
%
% figure
% obj_A.draw
% obj_B.draw
%
% obj_A.boundingBox.draw
% obj_B.boundingBox.draw
%
% scatter3(randomPoint_A(1),randomPoint_A(2),randomPoint_A(3),'x')
% scatter3(randomPoint_B(1),randomPoint_B(2),randomPoint_B(3))
%
% xlabel('{\fontname{times}{\itx}}');
% ylabel('{\fontname{times}{\ity}}');
% zlabel('{\fontname{times}{\itz}}');
%
% xticklabels({})
% yticklabels({})
% zticklabels({})
end

