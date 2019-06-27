%% this cell lets you explore the entire data file, as we did in the demo

opts.EMGfilename = 'flat_060,090,120';
opts.EMGdir = pwd;
opts.videodatafile = [];
opts.channels2use = 1:9;

opts.labels = {'L VL','L BFP','L TA','L LG','R VL','R BFP','R TA','R LG','ticker'};  % ALS labels

create_EMG_video_gui(opts)

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
ets.nsamp1 = samples(1);
ets.nsamp2 = samples(2);
ets.channels2use = opts.channels2use;
ets = updateData(ets);

data = ets.data;  % the data for the period
times = ets.time;  % the times for the period

%% if you know want to look at just that data in the same kind of gui:

myts = mytimeseries;  % this is a data class which is derived from timeseries
myts.Data = data;
myts.Time = times;
initialize_ts_gui(myts,[])   % this plots the gui with the controls so you can interact with the response
set_labels(opts.labels);
