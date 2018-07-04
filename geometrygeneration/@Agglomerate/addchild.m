function obj_A = addchild(obj_A,obj_B)
%ADDCHILD Summary of this function goes here
%   Detailed explanation goes here

% obj_C = obj_A.copy;

obj_A.childList = [obj_A.childList obj_B];
end

