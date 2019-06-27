function [nabove, nbelow, ntotal, thresh] = calc_response_above_thresh(data, onsetind, respind, nsd)
%function [nabove, nbelow, ntotal, thresh] = calc_response_above_thresh(data, onsetind, skipwindow, nsd)
%   Function which determines the number of samples above a threshold 
%   following a stimulation pulse.  DATA is a NSAMP X 1 vector, ONSETIND is
%   when the stimulation occured, SKIPWINDOW is the number of samples to
%   skip following the stimulation onset, NSD is the number of standard
%   deviations to use as the threshold.  The standard deviation is
%   calculated from the baseline condition.  NABOVE, NBELOW, NTOTAL are the
%   number of samples with activity above, below, or either above/below the
%   threshold value, minus the number expected by looking at the baseline
%   activity.  THRESH is the actual value of the threshold used.
%


if length(onsetind) == 1  % they only sent in a single time, so take from the beginning
    onset(1) = 1;
    onset(2) = onsetind;
elseif length(onsetind) ~= 2
    disp('Too many parameters for defining baseline?')
else
    onset = onsetind;
end

if length(respind) == 1  % the only sent in a single time, so take to the end
    resp(1) = respind;
    resp(2) = length(data);
elseif length(respind) ~=2
    disp('Too many parameters for defining response?')
else
    resp = respind;
end

nbase = length(onset(1):onset(2));
basesd = std(data(onset(1):onset(2)));
thresh = nsd*basesd + mean(data(onset(1):onset(2)));  % the threshold is the mean plus NSD*SD
nrand_above = length(find(data(onset(1):onset(2)) > thresh))/nbase;
nrand_below = length(find(data(onset(1):onset(2)) < -thresh))/nbase;
nsamp = length(resp(1):resp(2));  % the number of samples that go into the response

nabove = length(find(data(resp(1):resp(2)) > thresh)) - nrand_above*nsamp;  % the integrated activity minus the value expected by baseline
nbelow = length(find(data(resp(1):resp(2)) < -thresh)) - nrand_below*nsamp;  % allow for positive and negative
ntotal = nabove + nbelow;
