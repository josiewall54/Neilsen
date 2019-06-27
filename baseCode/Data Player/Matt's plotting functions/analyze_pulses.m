function analysis_results = analyze_pulses(filename,opts,window_times,varargin)

if nargin == 4  % they've sent in previous information
    prev_info = varargin{1};
    opts.pulses2analyze = prev_info.pulsenumber;  % use the pulse number they sent in
    filename = prev_info.datfile;  % use the data file that they sent in
end

[path,name,ext] = fileparts(filename);

opts.EMGfilename = [name ext];
opts.EMGdir = path;
    
sts = EMGTimeSeries(opts.EMGfilename,opts.EMGdir,'.lbv');
period = sts.period;
sts.channels2use = opts.channels2use;
nchan = length(opts.channels2use);
sts.downmeth = 'none';

[npulses,nind] = size(window_times);
if nind == 1  % if they only send in a single time, then use the pre/post pulse information
    temp = window_times;
    window_times(:,1) = temp - opts.pre_pulse_window;
    window_times(:,2) = temp + opts.post_pulse_window;
end

nsheet = 0;
clear all_XL_data
if strcmp(opts.pulses2analyze,'all')
    pulselist = 1:npulses;
else
    pulselist = opts.pulses2analyze;
end

for ii = pulselist  
    sts.nsamp1 = round(window_times(ii,1)/period);  %PulseSamples(ii) - opts.pre_pulse_window/period;
    sts.nsamp2 = round(window_times(ii,2)/period);; %PulseSamples(ii) + opts.post_pulse_window/period;
    fig = initialize_ts_gui(sts,[],gca);
    set_scales(ones(nchan,1)*opts.scale_factor);
    set_labels(opts.labels);

    if exist('prev_info')  % they've sent in previous information
        set_ided_times(prev_info.ided_times);
        set_notes(prev_info.notes);
    end

    if ~opts.blind
        set(gcf,'Name',[filename ' pulse # ' num2str(ii)])
    end
    uiwait(fig)  % user will have created ided_times and notes in the base workspace
    
%     all_XL_data{ii}{1,1} = 'NOTHING';  % default entry
    
    if exist('prev_info')  % if they sent in values for the ided_times and notes, use them as the defaults
        ided_times = prev_info.ided_times;
        notes = prev_info.notes;
    end
    try
        ided_times = evalin('base','ided_times');
        evalin('base','clear ided_times')
    end
    try
        notes = evalin('base','notes');
        evalin('base','clear notes')
    end
    if exist('ided_times') && exist('notes')
        nsheet = nsheet + 1;
        XL_data{1,1} = 'Filename';
        XL_data{2,1} = 'Pulse N';
        XL_data{3,1} = 'Notes 1';
        XL_data{4,1} = 'Notes 2';
        XL_data{5,1} = 'Notes 3';
        XL_data{1,2} = filename;
        XL_data{2,2} = ii;
        XL_data{3,2} = notes{1};
        XL_data{4,2} = notes{2};
        XL_data{5,2} = notes{3};

        for jj = 1:length(ided_times)
            [ntimes,ncol] = size(ided_times{jj});
            XL_data{6,(jj-1)*2+1} = ['Onsets ' num2str(jj)];
            XL_data{6,(jj-1)*2+2} = ['Offsets ' num2str(jj)];
            for kk = 1:ntimes
                XL_data{6+kk,(jj-1)*2+1} = ided_times{jj}(kk,1);
                XL_data{6+kk,(jj-1)*2+2} = ided_times{jj}(kk,2);
            end
        end
        all_XL_data{nsheet} = XL_data;
        clear XL_data
    else
        disp('you didn''t create ided_times and notes from the figure');
    end

    if exist('ided_times')  % these should be unnecessary
        clear ided_times
    end
    if exist('notes')
        clear notes
    end
end
if exist('all_XL_data')
    analysis_results = all_XL_data;
else
    analysis_results = {};
end

