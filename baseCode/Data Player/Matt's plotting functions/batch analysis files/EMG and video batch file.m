%% set up the options to control the analysis 

opts.labels = {'L VL','L BFp','L TA','L LG','R VL','R BFp','R TA','R LG','ticker bad', 'stim onset'};
opts.channels2use = [1:10];  % which channels to use from the data file
opts.ext = '';

opts.pulseNumber = [129 597 1249 1615 2541 353 4304 5048]; % on title of the figure
opts.frameNumber = [1128 1406 1795 2018 2573 3185 3629 4074];  % on the LED in the figure


%% to explore a data file just scrolling
opts.videodatafile = 'Movie_down.avi';  % the AVI video file
opts.EMGfilename = 'down';   % the name of the EMG file
opts.EMGdir = 'D:\PLT2_59\11-01-10';  % directory where the data is

opts.ext = '';  % no extension for the emg file (for some, this might be '.lbv')
cd(opts.EMGdir)  % move to the directory where the data is

create_EMG_video_gui(opts)  % makes the figure with EMGs and video
set_scales(.15*ones(1,length(opts.channels2use)));  % set the display gains on the display to be .2
