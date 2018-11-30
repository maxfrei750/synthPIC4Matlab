function faceCentroid = getboundingboxfacecentroid(obj,desiredFaceNormal)
%GETBOUNDINGBOXFACECENTROID Summary of this function goes here
%   Detailed explanation goes here

boundingBox = obj.boundingBox;

faceNormals = meshFaceNormals(boundingBox.vertices,boundingBox.faces_quads);

isRelevantFace = all(faceNormals == desiredFaceNormal,2);

faceCentroid = meshFaceCentroids( ...
    boundingBox.vertices, ...
    boundingBox.faces_quads(isRelevantFace,:));
end

