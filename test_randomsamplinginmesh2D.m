% Source: https://de.mathworks.com/matlabcentral/answers/327990-generate-random-coordinates-inside-a-convex-polytope#answer_257270

rng(1)

vertices = [1.18116604196553 0.800320709801823;-0.758453297283692 -1.50940472473439;-1.10961303850152 0.875874147834533;-0.558680764473972 -1.96541870928278;0.178380225849766 -1.27007139263854;0.586442621667069 2.02916018474976];
faces = [2 4;4 5;5 1;1 6;6 3;3 2];

plot(vertices(:,1),vertices(:,2),'bo');
hold on
plot([vertices(faces(:,1),1),vertices(faces(:,2),1)]',[vertices(faces(:,1),2),vertices(faces(:,2),2)]','r-')

% Calculate the mean of the coordinates of the vertices.
centerVertex = mean(vertices,1);

% Append centerpoint to the vertices.
vertices(end+1,:) = centerVertex;
indexCenterVertex = size(vertices,1);

% Create segments.
nSegments = size(faces,1);
segments = [faces,repmat(indexCenterVertex,nSegments,1)];

figure
plot(vertices(:,1),vertices(:,2),'bo');
hold on
plot([vertices(segments(:,1),1),vertices(segments(:,2),1),vertices(segments(:,3),1)]',[vertices(segments(:,1),2),vertices(segments(:,2),2),vertices(segments(:,3),2)]','g-')

% Calculate volumes of the segments.
segmentVolumes = zeros(1,nSegments);

for iSegment = 1:nSegments
  segmentVolumes(iSegment) = abs(det(vertices(segments(iSegment,1:2),:) - centerVertex));
end

% Normalize volumes.
segmentVolumes = segmentVolumes/sum(segmentVolumes);

%% Sample random points
nRandomPoints = 1000;

% Distribute the sampled points uniformly to the segments, relative to the 
% segment volumes.
[~,~,segmentIndices] = histcounts(rand(nRandomPoints,1),cumsum([0,segmentVolumes]));

r1 = rand(nRandomPoints,1);
uv = vertices(segments(segmentIndices,1),:).*r1 + vertices(segments(segmentIndices,2),:).*(1-r1);
r2 = sqrt(rand(nRandomPoints,1));
uv = uv.*r2 + vertices(segments(segmentIndices,3),:).*(1-r2);

figure
plot(vertices(:,1),vertices(:,2),'bo');
hold on
plot([vertices(segments(:,1),1),vertices(segments(:,2),1),vertices(segments(:,3),1)]',[vertices(segments(:,1),2),vertices(segments(:,2),2),vertices(segments(:,3),2)]','g-')
plot(uv(:,1),uv(:,2),'m.')