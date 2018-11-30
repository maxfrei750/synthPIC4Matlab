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

if not(any(collisionDirectionConstraint == 0))
    % Select a random point on the relevant faces of the bounding boxes of
    % obj_A and obj_B.
    randomPoint_A = getrandompointonboundingboxface( ...
        obj_A, ...
        boundingBoxStitchingFaceNormal_A);
    
    randomPoint_B = getrandompointonboundingboxface( ...
        obj_B, ...
        boundingBoxStitchingFaceNormal_B);
    
    % Calculate the translation vector.
    translationVector = randomPoint_A-randomPoint_B;
else
    % Calculate the center points of the relevant faces of the bounding
    % boxes of obj_A and obj_B.
    faceCentroid_A = ...
        getboundingboxfacecentroid(obj_A,boundingBoxStitchingFaceNormal_A);
    faceCentroid_B = ...
        getboundingboxfacecentroid(obj_B,boundingBoxStitchingFaceNormal_B);
    
    % Calculate the translation vector.
    translationVector = faceCentroid_A-faceCentroid_B;
end
    
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

