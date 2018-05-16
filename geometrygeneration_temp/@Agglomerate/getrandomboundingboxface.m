function faceNormal = getrandomboundingboxface(obj)
%GETRANDOMBOUNDINGBOXFACE Returns the |faceNormal| of a random face of a boundingBox.
%   The random picking of the face is weighted according to the size of the
%   faces.

dimensions = obj.boundingBox.dimensions;

delta_x = dimensions(1);
delta_y = dimensions(2);
delta_z = dimensions(3);

% Determine probabilities of faces to be selected. The probabilities are
% proportional to the area of the faces. Opposing faces have identical
% probabilities.
probability = zeros(1,3);

probability(1) = rand*(delta_y*delta_z); % [1 0 0]- or [-1 0 0]-face
probability(2) = rand*(delta_x*delta_z); % [0 1 0]- or [0 -1 0]-face
probability(3) = rand*(delta_x*delta_y); % [0 0 1]- or [0 0 -1]-face

% The opposing faces with the highest probability are selected.
[~,index] = max(probability);

faceNormal = zeros(1,3);
faceNormal(index) = 1;

% Select one of the two opposing faces by randomly fliping the face-normal.
faceNormal = (-1)^randi(2)*faceNormal;
end