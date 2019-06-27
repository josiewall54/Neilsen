%%  this is just to plot and explore a file

opts.EMGfilename = 'stim1_1000';
opts.EMGdir = pwd;
opts.videodatafile = [];
opts.channels2use = 1:9;

opts.labels = {'L VL','L BFP','L TA','L LG','R VL','R BFP','R TA','R LG','ticker'};  % ALS labels
% opts.labels = {'R LG','R TA','R BFP','R VL','L LG','L TA','L BFP','L VL','ticker'}; 
% opts.labels = {'R VL','R BFP','R TA','R LG','L VL','L BFP','L TA','L LG','ticker'};

% opts.frameNumber = [1744 3322 4798 6348 7620];
% opts.pulseNumber = [1958 4589 7052 9638 11707];

create_EMG_video_gui(opts)

%%  options for setting up the analyses of separate pulses

filename = 'flat_060,090,120';
opts.pinchChannel = 1;
opts.threshold = 1;
opts.labels = {'R LG','R TA','R BFP','R VL','L LG','L TA','L BFP','L VL','ticker'};
opts.channels2use = 1:9;
opts.min_repeat_window = .25;  % the mininum time between pulses
opts.pre_pulse_window = 2;
opts.post_pulse_window = 10;
opts.scale_factor = .4;
opts.pulses2analyze = 'all';
opts.pulses2analyze = 1:3;

%% find the pulse onsets, using the above information

PulseTimes = find_pulses(filename,opts);

%%  analyze the pulses using the options set above

analysis_results = analyze_pulses(filename,opts,PulseTimes);

%% now write the results to an excel spreadsheet

xls_filename = [filename '_analysis5'];
for ii = 1:length(analysis_results)
        xlswrite(xls_filename,analysis_results{ii},ii);
end

%%  now replay the information from the xls spreadsheet

sheetn = 2;  % particular sheet to check

xls_info = read_xls_pulse_file(xls_filename,sheetn);
analysis_results2 = analyze_pulses(filename,opts,PulseTimes,xls_info);

% note that the results returned by the above function call only give the
% information for a single pulse - if you want to rewrite a sheet in the
% xls file, you'll have to write that specific sheet back in.  Also, you
% have to be careful about erasing the entire set of information in the
% original file.

%%  now rewrite the excel spreadsheet with the modified data

xlswrite(xls_filename,analysis_results2{1},sheetn);  % for just the relevant sheet

