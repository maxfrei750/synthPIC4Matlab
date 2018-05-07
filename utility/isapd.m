function tf = isapd(candidate)
%ISAPD Determines whether an object is a probability distribution.
%   Returns true, if the candidate is a probability distribution.
candidateClass = class(candidate);

tf = strcmp(candidateClass(1:5),'prob.');
end

