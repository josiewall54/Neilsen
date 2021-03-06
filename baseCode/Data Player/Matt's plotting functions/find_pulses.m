function [PulseTimes, PulseSamples] = find_pulses(filename,opts)
% returns times of pulses - not indices

[path,name,ext] = fileparts(filename);
opts.EMGfilename = [name ext];
opts.EMGdir = path;
    
sts = EMGTimeSeries(opts.EMGfilename,opts.EMGdir,['.' opts.ext]);

% find the pulse onsets
[meanInterval, minInterval, maxInterval, nIntervals,PulseSamples] = getMeanPulseInterval(sts, [opts.EMGdir '\' opts.EMGfilename], opts.pinchChannel,opts.threshold,0);
period = sts.period;
temp = diff(PulseSamples);
ind = find(temp > opts.min_repeat_window/period);  % get rid of any pulses within 250ms of one another
PulseSamples = PulseSamples([ind end])';
if ~isempty(ind)
    PulseTimes = PulseSamples*period;  % return the times
else
    PulseTimes = [];
end

