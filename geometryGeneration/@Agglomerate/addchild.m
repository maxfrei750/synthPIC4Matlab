function obj_C = addchild(obj_A,obj_B)
%ADDCHILD Summary of this function goes here
%   Detailed explanation goes here

obj_C = obj_A;

obj_C.childList = [obj_A.childList obj_B.childList];
obj_C.nChildren = obj_A.nChildren+obj_B.nChildren;
end

