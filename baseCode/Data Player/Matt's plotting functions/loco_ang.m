function [allmeanang, meanang, meancos, meansin] = loco_ang(data)
%function [allmeanang, meanang, meancos, meansin] = loco_ang(data)
%   Function to calculate the mean angle of a burst.  DATA is the burst
%   data matrix which should be NCYCLES by NSAMP.  Each row should have one
%   cycle.  Each cycle should be NSAMP long (normalized cycle length).
%   Calculates the mean phase angle of each burst, with -pi being the start of
%   the cycle and pi being the end.  Also returns the mean cosine and sine
%   for each individual burst.  MNANG has the overall averaged angle,
%   weighted by the concentration of the activity in each cycle.
%   ALLMEANANG has the angle for each individual cycle. (Note that the
%   angular mean of ALLMEANANG will not be equal to MNANG).  MEANCOS and
%   MEANSIN, give the sin and cos for each individual cycle - this is the
%   data that is used to calcualte MNANG.  
%

[ncyc,nsamp] = size(data);

phase = linspace(-pi,pi,nsamp);
allcos = repmat(cos(phase),ncyc,1).*data;
allsin = repmat(sin(phase),ncyc,1).*data;

meancos = sum(allcos')./sum(data,2)';
meansin = sum(allsin')./sum(data,2)';

allmeanang = atan2((meansin),(meancos));

meanang = atan2(mean(meansin),mean(meancos));

