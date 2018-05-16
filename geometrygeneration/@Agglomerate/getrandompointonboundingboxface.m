function randomPoint = getrandompointonboundingboxface(obj,desiredFaceNormal)
%GETRANDOMPOINTONBOUNDINGBOXFACE Summary of this function goes here
%   Detailed explanation goes here

boundingBox = obj.boundingBox;

faceNormals = boundingBox.faceNormals;

isRelevantFace = all(faceNormals == desiredFaceNormal,2);

randomPoint = random_points_on_mesh( ...
    boundingBox.vertices, ...
    boundingBox.faces(isRelevantFace,:),1);
end

