%%

opts.EMGfilename = 'flat_060,090,120';
% opts.EMGfilename = 'flat';
opts.EMGdir = pwd;
opts.videodatafile = [];
opts.channels2use = 1:4;
opts.labels = {'R LG','R TA','R BFP','R VL','L LG','L TA','L BFP','L VL','ticker'};
% opts.labels = {'R VL','R BFP','R TA','R LG','L VL','L BFP','L TA','L LG','ticker'};

% opts.scales =
opts.frameNumber = [1744 3322 4798 6348 7620];
opts.pulseNumber = [1958 4589 7052 9638 11707];

create_EMG_video_gui(opts)

%%  options for setting up the analyses

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
opts.pulses2analyze = 2;

analysis_results = analyze_pulses(filename,opts);

%% now write the results to an excel spreadsheet

nsheets = 1;
xls_filename = [filename '_analysis'];
for ii = 1:length(analysis_results)
    if ~isempty(analysis_results{ii})
        xlswrite(xls_filename,analysis_results{ii},nsheets);
        nsheets = nsheets +1;
    end
end


%%

opts.EMGfilename = 'VM12002.lbv';
opts.EMGdir = pwd;
opts.videodatafile = '20090625VM12_pinch.avi';
opts.channels2use = [1:8 17];
opts.labels = {'R LG','R TA','R BFP','R VL','L LG','L TA','L BFP','L VL','ticker'};

% opts.scales =
opts.frameNumber = [1188 3051 4256 5570 6806];
opts.pulseNumber = [1260 4368 6378 8588 10631];

create_EMG_video_gui(opts)

%%



opts.EMGfilename = 'Pinch';
opts.EMGdir = pwd;
opts.videodatafile = '20090728VM24_Down.avi';
opts.channels2use = [1:9 17];
opts.labels = {'R LG','R TA','R BFP','R VL','L LG','L TA','L BFP','L VL', 'record','ticker'};

% opts.scales =
opts.frameNumber = [1171 1841 2330 2973 8148];
opts.pulseNumber = [1634 2749 3568 4639 5254];

create_EMG_video_gui(opts)

%%

opts.EMGfilename = 'VM12004.lbv';
opts.EMGdir = pwd;
opts.videodatafile = '20090625VM12_flat.avi';
opts.channels2use = [1:8 17];
opts.labels = {'R LG','R TA','R BFP','R VL','L LG','L TA','L BFP','L VL','ticker'};

% opts.scales =
opts.frameNumber = [1305 3053 4465 5828 7063];
opts.pulseNumber = [1527 4442 6798 9071 11131];

create_EMG_video_gui(opts)

%%
opts.EMGfilename = 'VM12005.lbv';
opts.EMGdir = pwd;
opts.videodatafile = '20090625VM12_down7,5.avi';
opts.channels2use = [1:8 17];
opts.labels = {'R LG','R TA','R BFP','R VL','L LG','L TA','L BFP','L VL','ticker'};

% opts.scales =
opts.frameNumber = [930 2376 3651 4842 5962];
opts.pulseNumber = [315 2726 4854 6843 8709];

create_EMG_video_gui(opts)

