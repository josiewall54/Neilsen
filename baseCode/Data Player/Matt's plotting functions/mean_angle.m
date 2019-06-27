function mnang = mean_angle(angles)
%function mnang = mean_angle(angles)
%   Functino to find the angular mean of a set of angles.
%

allcos = cos(angles);
allsin = sin(angles);
mnang = atan2(mean(allsin),mean(allcos));
