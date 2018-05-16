clear
close all

nRays = 100;
nPixels = nRays;
nPolygons = 200;

distances = rand(nRays,nPolygons);
flags = logical(randi(2,nRays,nPolygons)-1);

distances = mat2cell(distances,ones(nPixels,1));
flags = mat2cell(flags,ones(nPixels,1));

%C = cellfun(@(x) x, flags,'UniformOutput',false);



C = cellfun(removeNaNs,distances);



