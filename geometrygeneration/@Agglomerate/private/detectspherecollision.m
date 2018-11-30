function tf = detectspherecollision(mesh_A,mesh_B)
%DETECTSPHERECOLLISION Summary of this function goes here
%   Detailed explanation goes here

distance = sqrt(sum((mesh_A.centroid-mesh_B.centroid).^2));

radius_A = mean(range(mesh_A.vertices))/2;
radius_B = mean(range(mesh_B.vertices))/2;

tf = (distance <= radius_A + radius_B);
end

