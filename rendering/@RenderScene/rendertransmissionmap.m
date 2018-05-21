function transmissionMap = rendertransmissionmap(transmissionLengthMap,transmissionCoefficient)
%RENDERTRANSMISSIONMAP Calculates the relative transmission intensities.
%   Source: Hornbogen, Skrotzki: Mikro- und Nanoskopie der Werkstoffe

transmissionMap = ...
    exp(-transmissionCoefficient*transmissionLengthMap);

end

