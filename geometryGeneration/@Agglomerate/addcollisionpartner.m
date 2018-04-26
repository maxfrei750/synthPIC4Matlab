function obj_A = addcollisionpartner(obj_A,obj_B)
%ADDCOLLISIONPARTNER Summary of this function goes here
%   Detailed explanation goes here
obj_A.collisionPartnerList = [obj_A.collisionPartnerList obj_B];
end

