function transmissionDistance = treateven4plushitrays(intersectionDistances,intersectionFlags,facesObjectIDs)
%TREAT4PLUSEVENHITRAYS Summary of this function goes here
%   Detailed explanation goes here

% Keep only intersectionDistances and facesObjectIDs of
% intersected faces.
intersectionDistances = ...
    intersectionDistances(intersectionFlags);
facesObjectIDs = facesObjectIDs(intersectionFlags);

% Sort intersectionDistances andfacesObjectIDs according to
% intersectionDistances.
[intersectionDistances,orderedIndices] = ...
    sort(intersectionDistances);
facesObjectIDs = facesObjectIDs(orderedIndices);

nIntersections = size(facesObjectIDs,1);
alreadyEncounteredFacesObjectIDs = NaN(nIntersections,1);

relevantIntersectionDistances = NaN(nIntersections,1);

% skip first iteration
isInsideObjectCounter = 1;
alreadyEncounteredFacesObjectIDs(1) = facesObjectIDs(1);
relevantIntersectionDistances(1) = intersectionDistances(1);

for iIntersection = 2:nIntersections
    facesObjectID = facesObjectIDs(iIntersection);
    
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
objectTransmissionDistances = ...
    relevantIntersectionDistances - ...
    [0;relevantIntersectionDistances(1:end-1)];

objectTransmissionDistances = ...
    objectTransmissionDistances(2:2:end);

transmissionDistance = sum(objectTransmissionDistances);
end

