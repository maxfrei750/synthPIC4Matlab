function pixelData = computepixeldata(obj)
%COMPUTEPIXELDATA Summary of this function goes here
%   Detailed explanation goes here

width = obj.size(2);
height = obj.size(1);

[x,y] = meshgrid(1:width,1:height);

directionVector = [sind(obj.angleDegree) cosd(obj.angleDegree)];
gradientLength = width/cosd(obj.angleDegree);

pixelData = (x*directionVector(1)+y*directionVector(2))*obj.steepness/gradientLength;

end

