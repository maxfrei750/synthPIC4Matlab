function randomPoints = getrandompointsinmesh(mesh,nRandomPoints)
%GETRANDOMPOINTSINMESH Generates random points inside a mesh.
%   Source: https://de.mathworks.com/matlabcentral/answers/327990-generate-random-coordinates-inside-a-convex-polytope#answer_257270


%% Validate inputs.
validateattributes(mesh,{'Mesh'},{'numel',1});

validateattributes( ...
    nRandomPoints, ...
    {'numeric'}, ...
    {'real','finite','nonnan','nonsparse','nonempty','positive','scalar'});

%% Calculate 3d segments of the mesh.
vertices = mesh.vertices;
faces = mesh.faces;

% Calculate the mean of the coordinates of the vertices.
centerPoint = mean(vertices,1);

% Append centerpoint to the vertices.
vertices(end+1,:) = centerPoint;
indexCenterPoint = size(vertices,1);

% Create segments.
nSegments = size(faces,1);
segment = [faces,repmat(indexCenterPoint,nSegments,1)];

% Calculate volumes of the segments.
segmentVolumes = zeros(1,nSegments);

for iSegment = 1:nSegments
  segmentVolumes(iSegment) = abs(det(vertices(segment(iSegment,1:3),:) - centerPoint));
end

% Normalize volumes.
segmentVolumes = segmentVolumes/sum(segmentVolumes);

%% Sample random points

% Distribute the sampled points uniformly to the segments, relative to the 
% segment volumes.
[~,~,segmentIndices] = histcounts(rand(nRandomPoints,1),cumsum([0,segmentVolumes]));

r1 = rand(nRandomPoints,1);
randomPoints = ...
    vertices(segment(segmentIndices,1),:).*r1 + ...
    vertices(segment(segmentIndices,2),:).*(1-r1);

r2 = sqrt(rand(nRandomPoints,1));
randomPoints = ...
    randomPoints.*r2 + ...
    vertices(segment(segmentIndices,3),:).*(1-r2);

r3 = nthroot(rand(nRandomPoints,1),3);
randomPoints = ...
    randomPoints.*r3 + ...
    vertices(segment(segmentIndices,4),:).*(1-r3);

end

