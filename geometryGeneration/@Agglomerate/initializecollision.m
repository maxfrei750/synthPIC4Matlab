function collisionDirection = initializecollision(obj_A,obj_B)
%INITIALIZECOLLISION initializes the collision.

%% Stitch the bounding boxes of obj_A and obj_B together 
% Select a random facenormal of the boundingBox_A for the stitching.
boundingBoxStitchingFaceNormal_A = getrandomboundingboxface(obj_A);

% The stitching-faceNormal of obj_B is antiparallel to the
% stitching-faceNormal of obj_A.
boundingBoxStitchingFaceNormal_B = -boundingBoxStitchingFaceNormal_A;

% Select a random point on the relevant faces of the bounding boxes of
% each obj_A and obj_B.
randomPoint_A_0 = getrandompointonboundingboxface( ...
    obj_A, ...
    boundingBoxStitchingFaceNormal_A);

randomPoint_B_0 = getrandompointonboundingboxface( ...
    obj_B, ...
    boundingBoxStitchingFaceNormal_B);

% Calculate the translation vector.
translationVector = randomPoint_A_0-randomPoint_B_0;

% Translate mesh_B so that the random points are aligned.
obj_B.mesh = obj_B.mesh.translate(translationVector);

%% Calculate collision direction.
collisionDirection = normalizeVector3d(obj_A.centroid-obj_B.centroid);

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

