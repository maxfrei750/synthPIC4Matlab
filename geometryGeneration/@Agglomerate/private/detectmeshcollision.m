function tf = detectmeshcollision(mesh_A,mesh_B)
%DETECTMESHCOLLISION Summary of this function goes here
%   Detailed explanation goes here

nIterations = 3;

tf = GJK(mesh_A,mesh_B,nIterations);

end

