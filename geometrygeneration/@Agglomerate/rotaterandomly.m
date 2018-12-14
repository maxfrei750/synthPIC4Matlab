function obj = rotaterandomly(obj)

% Roll a random rotation axis and angle.
axisDirection = normalizeVector3d(randn(1,3));
angleDegree = randd([0 360]);

% Perform rotation.
obj = rotatearoundaxis(obj,axisDirection,angleDegree);
end