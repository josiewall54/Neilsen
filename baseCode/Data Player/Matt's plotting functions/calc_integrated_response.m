function [ratio, total] = calc_integrated_response(data, onsetind, respind)
%function [ratio, total] = calc_integrated_response(data, onsetind, respind)
%    Function to calculate the integrated activity in a trace.  DATA is a
%    NSAMP X 1 data vector which has the response evoked by a stimulation.
%    ONSETIND is the index into DATA at which the stimulation was applied.
%    It calculates the integrated activity expected above baseline.
%    SKIPWINDOW has the number of samples to skip before starting the
%    calculation, to allow for ignoring stimulation artefact.  NB: assumes
%    the data is already rectified.  RATIO returns the ratio of the
%    response to that expected by chance (1 is chance).  TOTAL returns the
%    total integrated activity above chance levels.  This is in whatever
%    units are sent in so the actual numbers are hard to interpret
%    directly.  RESPIND specifies the 
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

baseline = sum(data(onset(1):onset(2)));
baserate = baseline/(length(onset(1):onset(2)));  % the expected integrated value per sample

nsamp = length(resp(1):resp(2));  % the number of samples that go into the response
ratio = sum(data(resp(1):resp(2)))/(baserate*nsamp);  % the integrated activity divided by the value expected by baseline
total = sum(data(resp(1):resp(2))) - (baserate*nsamp);  % the integrated activity minus the value expected by baseline
