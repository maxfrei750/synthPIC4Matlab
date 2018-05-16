test_raytracing_tem_cpuclear
close all

position = [0 0 0];
scale = 100;

[vertices,faces] = createIcosphere;
vertices = vertices*scale+position;

tic;
vertices_x = vertices(:,1);
vertices_y = vertices(:,2);
vertices_z = vertices(:,3);

% Determin borders of the bounding box.
x_min = min(vertices_x);
x_max = max(vertices_x);

y_min = min(vertices_y);
y_max = max(vertices_y);

z_min = min(vertices_z);
z_max = max(vertices_z);

rayDirection = [0 0 -1];

x_steps = linspace(x_min,x_max,x_max-x_min);
y_steps = linspace(y_min,y_max,y_max-y_min);

nSteps_x = numel(x_steps);
nSteps_y = numel(y_steps);

thicknessMap = zeros(nSteps_x,nSteps_y);

% Iterate all pixels of the xy-plane
for i = 1:nSteps_x
    x = x_steps(i);
    
    for j = 1:nSteps_y
        y = y_steps(j);
        rayOrigin = [x y z_max+1];
        
        [isIntersecting,rayPositionParameter,~] = ...
            ray_mesh_intersect(rayOrigin,rayDirection, vertices, faces);
        
        nIntersections = sum(isIntersecting);
        
        if nIntersections < 2
            intersectionDistance = 0;
        else
            intersectionPositionParameters = ...
                rayPositionParameter(isIntersecting);
            
            % Remove redundant data points.
            intersectionPositionParameters = ...
                minmax(intersectionPositionParameters')';
            
            interSectionPositions = ...
                rayOrigin+rayDirection.*intersectionPositionParameters;
            
            intersectionDistance = ...
                sqrt(sum(interSectionPositions(1,:)-interSectionPositions(2,:)).^2);
        end
        
        thicknessMap(i,j) = intersectionDistance;
        
    end
end
toc;

transmissionCoefficient = 0.01;
intensityMap = exp(-transmissionCoefficient*thicknessMap);
imshow(intensityMap);