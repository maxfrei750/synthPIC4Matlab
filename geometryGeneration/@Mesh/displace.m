function obj = displace(obj,noise3d)
%DISPLACE Summary of this function goes here
%   Detailed explanation goes here

% Get noise amplitudes at the vertices of the mesh.
noiseAmplitudes = noise3d.getamplitudesforpoints(obj.vertices);

% Generate random offsets for each point in direction of the vertexNormals.
deformationOffsets = obj.vertexNormals.*noiseAmplitudes;

% Apply the deformation.
obj.vertices = obj.vertices+deformationOffsets;
end

