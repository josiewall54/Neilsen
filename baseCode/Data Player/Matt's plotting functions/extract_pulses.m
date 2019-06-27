function [alldat, opts, alltimes] = extract_pulses(filename,opts)
%function [alldata] = extract_pulses(filename,opts)
%   
%

if ~isfield(opts,'PulseSamples')  % if they don't specify PulseSamples in the input, then find them
    [PulseTimes, PulseSamples] = find_pulses(filename,opts);
    opts.PulseSamples = PulseSamples;
end

[path,name,ext] = fileparts(filename);

opts.EMGfilename = [name ext];
opts.EMGpath = path;
    
sts = EMGTimeSeries(opts.EMGfilename,opts.EMGpath,['.' opts.ext]);
period = sts.period;
sts.channels2use = opts.channels2use;
nchan = length(opts.channels2use);
% sts.downmeth = 'none';

npulses = length(opts.PulseSamples);
temp = opts.PulseSamples;  % find the pre and post windows for extracting data
window_samples(:,1) = temp - round(opts.pre_pulse_window/period);
window_samples(:,2) = temp + round(opts.post_pulse_window/period);

for ii = 1:npulses  
    sts.nsamp1 = round(window_samples(ii,1));  %PulseSamples(ii) - opts.pre_pulse_window/period;
    sts.nsamp2 = round(window_samples(ii,2));; %PulseSamples(ii) + opts.post_pulse_window/period;
    sts = updateData(sts);
    dat = sts.Data;
    times = sts.Time;
    alldat(:,ii,1:size(dat,1)) = dat';
    alltimes(1:length(times),ii) = times';
    
    if opts.display
        fig = initialize_ts_gui(sts,[],gca);
        set(gcf,'Name',[filename ' pulse # ' num2str(ii)])
%         set_scales(ones(nchan,1)*opts.scale_factor);
        set_labels(opts.labels);
        uiwait(fig)
    end
end

opts.samprate = sts.dataInfo.samprate;

