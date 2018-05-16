% Source: https://de.mathworks.com/matlabcentral/answers/327990-generate-random-coordinates-inside-a-convex-polytope#answer_257270

clear
close all

rng(1)

%% Generate a random mesh for testing.
randomPoints = rand(10,3);
faces = convhulln(randomPoints);

% Keep only vertices on the surface of the mesh.
vertexIndices = unique(faces);
vertices = randomPoints(vertexIndices,:);

% Update the faces.
faces = convhulln(vertices);

clear randomPoints vertexIndices

%%

plot3(vertices(:,1),vertices(:,2),vertices(:,3),'bo');

hPatch = drawMesh(vertices,faces);
hPatch.FaceAlpha = 0.2;

% Calculate the mean of the coordinates of the vertices.
centerVertex = mean(vertices,1);

% Append centerpoint to the vertices.
vertices(end+1,:) = centerVertex;
indexCenterVertex = size(vertices,1);

% Create segments.
nSegments = size(faces,1);
segment = [faces,repmat(indexCenterVertex,nSegments,1)];

figure
plot3(vertices(:,1),vertices(:,2),vertices(:,3),'bo');

colorList = jet(nSegments);

for iSegment = 1:nSegments
    segmentVertices = vertices(segment(iSegment,:),:);
    segmentFaces = convhulln(segmentVertices);
    
    hPatch = drawMesh(segmentVertices,segmentFaces);
    hPatch.FaceAlpha = 0.2;
    hPatch.FaceColor = colorList(iSegment,:);
end

% Calculate volumes of the segments.
segmentVolumes = zeros(1,nSegments);

for iSegment = 1:nSegments
  segmentVolumes(iSegment) = abs(det(vertices(segment(iSegment,1:3),:) - centerVertex));
end

% Normalize volumes.
segmentVolumes = segmentVolumes/sum(segmentVolumes);

%% Sample random points
nRandomPoints = 100000;

% Distribute the sampled points uniformly to the segments, relative to the 
% segment volumes.
[~,~,segmentIndices] = histcounts(rand(nRandomPoints,1),cumsum([0,segmentVolumes]));

r1 = rand(nRandomPoints,1);
uvw = vertices(segment(segmentIndices,1),:).*r1 + vertices(segment(segmentIndices,2),:).*(1-r1);
r2 = sqrt(rand(nRandomPoints,1));
uvw = uvw.*r2 + vertices(segment(segmentIndices,3),:).*(1-r2);
r3 = nthroot(rand(nRandomPoints,1),3);
uvw = uvw.*r3 + vertices(segment(segmentIndices,4),:).*(1-r3);

figure
plot3(vertices(:,1),vertices(:,2),vertices(:,3),'bo');

hPatch = drawMesh(vertices,faces);
hPatch.FaceAlpha = 0.2;
hold on
plot3(uvw(:,1),uvw(:,2),uvw(:,3),'m.')