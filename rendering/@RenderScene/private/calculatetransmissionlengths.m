function transmissionLengths = calculatetransmissionlengths(intersectionDistancesArray,intersectionFlagsArray,facesObjectIDs)
%CALCULATETRANSMISSIONLENGTHS Summary of this function goes here
%   Detailed explanation goes here

nRays = size(intersectionDistancesArray,1);

%% Initialization
% Transpose ray tracing outputs.
intersectionDistancesArray = intersectionDistancesArray';
intersectionFlagsArray  = intersectionFlagsArray';

% Gather data from gpu to improve speed (sic!).
intersectionDistancesArray = gather(intersectionDistancesArray);
intersectionFlagsArray = gather(intersectionFlagsArray);

%% Group rays.
% Maybe don't use indices, but logical indexing?

rayIndices = 1:nRays;
nHitsArray = sum(intersectionFlagsArray,1);

% 0 hit rays
isHitRay_0 = nHitsArray == 0;
rayIndices_0Hits = rayIndices(isHitRay_0);

% uneven hit rays
isHitRay_unevenNumberOfHits = ~isEven(nHitsArray);
rayIndices_unevenNumberOfHits = ...
    rayIndices(isHitRay_unevenNumberOfHits);

% 2 hit rays
isHitRay_2 = nHitsArray == 2;
rayIndices_2Hits = rayIndices(isHitRay_2);

% 4+ even hit rays
isHitRay_even4plus = nHitsArray >= 4 & isEven(nHitsArray);
rayIndices_4HitsPlus = rayIndices(isHitRay_even4plus);

%% Initialize transmissionDistanceMapTile.
transmissionLengths = zeros(nRays,1);

%% Treat 0 hit rays.
% Could be ommited, because transmissionDistances was
% initialized with 0. However, this is more robust.
transmissionLengths(rayIndices_0Hits) = 0;

%% Treat rays with an uneven number of hits.
% Rays with an uneven number of hits are assumed to never leave
% some geometry, because there is no outgoing intersection.
% Therefore, the transmission distance is infinite.
transmissionLengths(rayIndices_unevenNumberOfHits) = inf;

%% Treat 2 hit rays.
% For rays with just 2 hits, the transmssion distance can be
% calculated based on the minimum and maximum transmission
% distance.
transmissionLengths(rayIndices_2Hits) = ...
    max(intersectionDistancesArray(:,rayIndices_2Hits)) - ...
    min(intersectionDistancesArray(:,rayIndices_2Hits));

%% Treat even 4+ hit rays.
for iRay = rayIndices_4HitsPlus
    % Select data of current ray.
    intersectionDistances = intersectionDistancesArray(:,iRay);
    intersectionFlags = intersectionFlagsArray(:,iRay);
    
    % Keep only intersectionDistances and facesObjectIDs of
    % intersected faces.
    intersectionDistances = ...
        intersectionDistances(intersectionFlags);
    relevantFacesObjectIDs = facesObjectIDs(intersectionFlags);
    
    % Sort intersectionDistances andfacesObjectIDs according to
    % intersectionDistances.
    [intersectionDistances,orderedIndices] = ...
        sort(intersectionDistances);
    relevantFacesObjectIDs = relevantFacesObjectIDs(orderedIndices);
    
    nIntersections = size(relevantFacesObjectIDs,1);
    alreadyEncounteredFacesObjectIDs = NaN(nIntersections,1);
    
    relevantIntersectionDistances = NaN(nIntersections,1);
    
    % skip first iteration
    isInsideObjectCounter = 1;
    alreadyEncounteredFacesObjectIDs(1) = relevantFacesObjectIDs(1);
    relevantIntersectionDistances(1) = intersectionDistances(1);
    
    for iIntersection = 2:nIntersections
        facesObjectID = relevantFacesObjectIDs(iIntersection);
        
        wasIntersectedBefore = ...
            facesObjectID == alreadyEncounteredFacesObjectIDs;
        
        if any(wasIntersectedBefore)
            % The ray is leaving an object.
            isInsideObjectCounter = isInsideObjectCounter-1;
            
            % If the ray is outside all objects now, then add
            % current intersectiondistance to the
            % relevantIntersectionDistances.
            if isInsideObjectCounter == 0
                relevantIntersectionDistances(iIntersection) = ...
                    intersectionDistances(iIntersection);
            end
            
            % Remove the facesObjectID from the list of
            % alreadyEncounteredFacesObjectIDs, so that it will
            % be processed again, if the object is concave and
            % hit again by the current ray.
            alreadyEncounteredFacesObjectIDs(wasIntersectedBefore) = NaN;
            
        else
            % The ray is entering a new object.
            isInsideObjectCounter = isInsideObjectCounter+1;
            
            % Add the object to the
            % alreadyEncounteredFacesObjectIDs.
            alreadyEncounteredFacesObjectIDs(iIntersection) = ...
                facesObjectID;
            
            % If the ray is only inside a single object now,
            % then add the current intersectiondistance to the
            % relevantIntersectionDistances.
            if isInsideObjectCounter == 1
                relevantIntersectionDistances(iIntersection) = ...
                    intersectionDistances(iIntersection);
            end
        end
    end
    
    % Remove NaNs from relevantIntersectionDistances.
    relevantIntersectionDistances(isnan(relevantIntersectionDistances)) = [];
    
    % Calculate the transmissionDistance of the current ray.
    objectTransmissionLengths = ...
        relevantIntersectionDistances - ...
        [0;relevantIntersectionDistances(1:end-1)];
    
    objectTransmissionLengths = ...
        objectTransmissionLengths(2:2:end);
    
    transmissionLengths(iRay) = sum(objectTransmissionLengths);
end

end

