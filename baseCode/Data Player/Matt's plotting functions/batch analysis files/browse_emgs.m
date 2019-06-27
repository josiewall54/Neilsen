%%  select the file and create the data object
[fname, path] = uigetfile('*.lbv');
ets = EMGTimeSeries(fname,path,'');
ets.channels2use = [1 2 3 4 5];  % the two EMG channels and the synchronizing pulse
ets.channels2use = [1 2 3 4 5 6 7 8 17];  % the two EMG channels and the synchronizing pulse
 ets = Setup_Pulse_Info(ets);  % set up the ability to find the pulse numbers
%% plot the data
initialize_ts_gui(ets,[]) % show the data in the gui
 
%% extract the data that's shown in the current screen

samples = get_view();
ets.nsamp1 = samples(1);
ets.nsamp2 = samples(2);
ets = updateData(ets);

data = ets.Data;  % the data for the period in the window
times = ets.Time;  % the times for the period in the window


 