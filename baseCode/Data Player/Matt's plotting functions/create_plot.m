function create_EMGvideo_gui(opts)

opts = get_default_opts(opts);

sts = EMGTimeSeries(opts.EMGfilename,opts.EMGdir,'.lbv');
sts.nsamp1 = 1;
sts.nsamp2 = sts.totNumSamples;
sts.channels2use = opts.channels2use;

v = VideoData(opts.videodatafile, opts.pulseNumber, opts.frameNumber);

initialize_ts_gui(sts,v);

if ~isempty(opts.labels)    
    set_labels(opts.labels);
end

if ~isempty(opts.scales)
    set_scales(opts.scales);
end


%%%%%%%%%%%%%%%%%%%%%
function opts = get_default_opts(opts)

defopts.EMGdir = pwd;
defopts.labels = {};
defopts.scales = [];
defopts.frameNumber = [0 1];
defopts.pulseNumber = [0 1];
defopts.channels2use = [];

fields = fieldnames(opts);
nfields =length(fields);
for i = 1:nfields
    defopts.(fields{i}) = opts.(fields{i});
end

opts = defopts;





