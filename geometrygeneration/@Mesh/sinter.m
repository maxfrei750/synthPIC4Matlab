function obj = sinter(obj,sinterParameter)
%SINTER Summary of this function goes here
%   Detailed explanation goes here

% Validate input.
validateattributes( ...
    sinterParameter, ...
    {'numeric'}, ...
    {'real','finite','nonnan','nonsparse','nonempty','scalar','integer','>=',0});

resolution = 0.1;

nSteps_x = round(obj.boundingBox.dimensions(1)*resolution);
nSteps_y = round(obj.boundingBox.dimensions(2)*resolution);
nSteps_z = round(obj.boundingBox.dimensions(3)*resolution);

voxels = VOXELISE(nSteps_x,nSteps_y,nSteps_z,obj.tostruct);
voxels = padarray(voxels,[1 1 1],0);

% Fix orientation.
voxels = rot90(voxels);
voxels = flip(voxels,1);

[tempFaces, tempVertices] = isosurface(voxels, 0.1);

% Fix scale.
tempDimensions = range(tempVertices);
tempScale = tempDimensions./obj.boundingBox.dimensions;
tempVertices = tempVertices./tempScale;

% Simulate sintering.
[tempVertices, tempFaces] = smoothMesh(tempVertices,tempFaces,sinterParameter);

% Create a new mesh.
sinteredMesh = Mesh(tempVertices,tempFaces);

% Fix position.
sinteredMesh = sinteredMesh.centerat(obj.centroid);

% Replace the mesh with the sintered version.
obj = sinteredMesh;
end

