%%  select the file and create the data object
[fname, path] = uigetfile('*.lbv');
ets = EMGTimeSeries(fname,path,'');
ets.channels2use = [1 2];
% ets.channels2use = [1:2];

% plot the data object
initialize_ts_gui(ets);  % plot the data

%%  % gets the window currently displayed in the window
samples = get_view();

%% extract the data for that time period
ets.nsamp1 = samples(1);
ets.nsamp2 = samples(2);
ets = updateData(ets);

data = ets.Data;  % the data for the period
times = ets.Time;  % the times for the period

%%  look at the spikes in the window you defined above

spt = sp_times(data(:,2),1);
plot(data(:,2))
spt = sp_times(data(:,2),.4);  % here .4 is the voltage threshold to use to determine when a spike 'event' occurs
aps = sp_extract(data(:,1),spt,20,30);
plot(aps')   % this plots the action potential waveforms, so you can see that it was a well isolated unit



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% BELOW THIS IS NOT USEFUL CURRENTLY, EXCEPT FOR INSPIRATION
%%  this cell lets you choose the file using the Matlab UI

[fname, path] = uigetfile();
opts.EMGfilename = fname;
opts.EMGdir = path;
opts.videodatafile = [];
opts.channels2use = 1:9;

opts.labels = {'L VL','L BFP','L TA','L LG','R VL','R BFP','R TA','R LG','ticker'};  % ALS labels

create_EMG_video_gui(opts)

%% this cell finds the sample numbers in the EMG file corresponding to pulse
% numbers as seen on the counter

counts = [10000 12000];  % the numbers on the counter for the beginning and end of the portion of the data that you're interested in

ets = EMGTimeSeries(opts.EMGfilename, opts.EMGdir,'.lbv'); % this creates a data object with the data information in it
samples = getSampleFromPulse(ets,counts);  % finds the sample numbers in the EMG data file which correspond with those counts


%%  this function just resets the view on the plot created using
%  create_EMG_video_gui

set_view(samples)

%%  if instead you want to pull out the data for this period of time...

ets = EMGTimeSeries(opts.EMGfilename, opts.EMGdir,'.lbv'); % this creates a data object with the data information in it
ets.channels2use = opts.channels2use;

ets.nsamp1 = samples(1);
ets.nsamp2 = samples(2);
ets = updateData(ets);

data = ets.data;  % the data for the period
times = ets.time;  % the times for the period

%% if you know want to look at just that data in the same kind of gui:

myts = mytimeseries;  % this is a data class which is derived from timeseries
myts.Data = data;
myts.Time = times;
initialize_ts_gui(myts,[])   % this plots the gui with the controls so you can interact with the response
set_labels(opts.labels);
