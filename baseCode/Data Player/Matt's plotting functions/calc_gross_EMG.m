function [gross_emg, sp_freq, cv, times] = calc_gross_emg(ets,channel,baseline,sptimes,window,startstop)
%function [gross_emg, sp_freq, times] = calc_gross_emg(ets,channel,baseline,window,startstop)
%
%   Function to calculate the gross emg from large EMG files, using the
%   subset time series data structures.
%   ETS is the EMG subset time series; CHANNEL is the index of the channel
%   in the ETS that has the gross EMG; BASELINE, is the period of time (in
%   seconds) where the baseline EMG level should be calculated - if
%   BASELINE is a single number then this is the value of the baseline; 
%   WINDOW is the amount of time that should be used to calculate the gross
%   EMG - this is effectively determining the downsampling of the EMG;
%   STARTSTOP defines the period of time within the file over which to
%   calculate the gross EMG (in seconds).
%
%   SPTIMES is the vector of spike times for the corresponding unit that
%   you want to analyze, in units of ms
%
%   Retursn the gross EMG, the spike frequency in each window, the
%   coefficient of variation of the unit in the window, and the time of the
%   center of each window.
%

samprate = 1/ets.period;

t_indices = startstop(1):window:startstop(end);
nwindows = length(t_indices)-1;

if length(baseline) == 2
    basedata = get(ets,'data',baseline);
    base_level = gross_emg_process(basedata(:,channel),samprate);
else
    base_level = baseline;
end

disp(nwindows)
for ii = 1:nwindows
    disp(ii)
    tind = [t_indices(ii) t_indices(ii+1)]; 
    tempdata = get(ets,'data',tind);   
    temp_level = gross_emg_process(tempdata(:,channel),samprate);
    gross_emg(ii) = temp_level - base_level;
    times(ii) = mean(tind);
    sp_inds = find((sptimes/1000 >= tind(1)) & (sptimes/1000 < tind(2)));
    sp_freq(ii) = length(sp_inds);
    isi = diff(sptimes(sp_inds));
    cv(ii) = std(isi)/mean(isi);
end

end


function level = gross_emg_process(data,sampling_rate)
%  just takes the abs then averages the data here
%  could get more sophisticated later on
%  

[b,a] = butter(2,50/(sampling_rate/2),'high');
data2 = filtfilt(b,a,data);

level = mean(abs(data2));

end
