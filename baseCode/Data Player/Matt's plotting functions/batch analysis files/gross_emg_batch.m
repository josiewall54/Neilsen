%%  select the file and create the data object
[fname, path] = uigetfile('*.lbv');
ets = EMGTimeSeries(fname,path,'');
ets.channels2use = [1:2];

%%
load File'001 Time87-88.8'.mat

goodind = find(clusters == 2);

%%  process the gross emg

%  send in the EMG data that has the gross EMG on channel 2, a baseline of
%  0, the spike times for the good unit, a window of 100ms, over the times
%  that are relevant for the data file
[gross_emg,sp_count,cv,win_times] = calc_gross_EMG(ets,2,0,sp_times(goodind),.1,[86 89]);


%%  now plot EMG before and after processing

 raw_fig = initialize_ts_gui(ets,[]) % before processing
 
 alldat(1,:) = gross_emg;
 alldat(2,:) = sp_count;

 ts = mytimeseries;
 ts.Data = alldat';
 ts.Time = win_times';

 proc_fig = initialize_ts_gui(ts,[])   % after processing

 %%  use this function to synchronize the views between the two windows
 %  e.g. if you're scrolling through the raw data and want to look at the
 %  corresponding times in the processed data then change the order of the
 %  numbers below  (i.e. you're synchronizing the view from the first
 %  figure to the second figure
 
 synch_views(proc_fig,raw_fig)
 
 
 
 
 