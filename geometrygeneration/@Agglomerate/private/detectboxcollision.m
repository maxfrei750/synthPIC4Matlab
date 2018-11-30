function tf = detectboxcollision(mesh_A,mesh_B)
%DETECTBOXCOLLISION Summary of this function goes here
%   Detailed explanation goes here

box_A = mesh_A.boundingBox;
box_B = mesh_B.boundingBox;

tf = ...
    (min(box_A.XData) <= max(box_B.XData) && max(box_A.XData) >= min(box_B.XData)) && ...
    (min(box_A.YData) <= max(box_B.YData) && max(box_A.YData) >= min(box_B.YData)) && ...
    (min(box_A.ZData) <= max(box_B.ZData) && max(box_A.ZData) >= min(box_B.ZData));
end

