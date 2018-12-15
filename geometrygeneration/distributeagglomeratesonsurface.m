function completeMesh = distributeagglomeratesonsurface(agglomerateList,surfaceMask,desiredCoverage)
%DISTRIBUTEAGGLOMERATESONSURFACE Summary of this function goes here
%   Detailed explanation goes here

nAgglomerates = numel(agglomerateList);

% Generate multiple aggloemrates.
completeMesh = Mesh.empty;

% Loop until the desired coverage is reached.
while true
    % Pick a random agglomerate from the list.
    iAgglomerate = randi(nAgglomerates);
    agglomerate = agglomerateList(iAgglomerate);
    
    % Rotate the agglomerate randomly.
    agglomerate.rotaterandomly;
    
    % Get mesh of the agglomerate.
    agglomerateMesh = agglomerate.completeMesh;
    
    % Pick a random position from the surfaceMask.
    [x,y] = pickrandompointonmask(surfaceMask);
    
    % Position mesh at the randomly picked point.
    agglomerateHeight = agglomerateMesh.boundingBox.dimensions(3);
    agglomeratePosition = [x y agglomerateHeight/2];
    agglomerateMesh = agglomerateMesh.centerat(agglomeratePosition);
    
    % Add the agglomerateMesh to the completeMesh.
    completeMesh = completeMesh+agglomerateMesh;
    
    % Break the loop when the desired coverage is reached.
    coverage = calculateimagecoverage(completeMesh,surfaceMask);
    if coverage >= desiredCoverage
        break
    end
end

end

