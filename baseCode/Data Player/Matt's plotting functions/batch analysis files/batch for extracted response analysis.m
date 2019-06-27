opts.pinchChannel = 10;  % which channel has the stim marker
opts.threshold = 1.5;  % the threshold for the stim marker
opts.labels = {'L VL','L BFp','L TA','L LG','R VL','R BFp','R TA','R LG','ticker bad', 'stim onset'};
opts.channels2use = [3 7 9 10]; %1:10;  % which channels to use from the data file
opts.min_repeat_window = .25;  % the mininum time between pulses
opts.pre_pulse_window = 2;  % the amount of time (in seconds) to extract before the pulse
opts.post_pulse_window = 10;  % the amount of time (in seconds) to extract after the pulse
opts.ext = '';
opts.display = 0;
opts.samplerate = 5000;
opts.baseline = [1 9000]; % the sample number where the stim occured - leave a margin to deal with filtering issues
opts.response = [11000 25000];  % number of samples after stim before starting calculations
opts.include_flags = {'Y'};


%%  find the stim onsets and extract data before and after the stim

fnames = dir('stim*.*');  % find all stim files
nfiles = length(fnames)

results = cell(nfiles,1);  % initialize the results
allnotes = cell(nfiles,1);
stimtimes = cell(nfiles,1);
for ii = 1:nfiles  % go through each file and extract the stimulation responses
    filename = fnames(ii).name;
    disp(filename)
    [pulse_responses, newopts] = extract_pulses(filename,opts); 
    results{ii} = pulse_responses;
    allnotes{ii} = filename;  % put the name of the file in the allnotes
    stimtimes{ii} = newopts.PulseSamples/newopts.samprate;
    disp(stimtimes{ii})
end

save allResults results allnotes stimtimes newopts

%% calculate the statistics about each response - integrated activity, etc..
%  this script high pass filters the data before calculating these, in
%  order to get rid of the slower baseline shifts, but the filtering of the
%  stim artefact causes small ripples around the stim time, so you need to
%  'blank' out that period before and after the stim response, which is why
%  the onset and artefactdur numbers are smaller and larger than might be
%  expected

if ~exist('newopts')
    newopts = opts;
end

dur = newopts.pre_pulse_window + newopts.post_pulse_window;

nfiles = length(results);
nmusc = size(results{1},1);
ntrials = zeros(nfiles,1);
for ii = 1:nfiles
    ntrials(ii) = size(results{ii},2);
end
maxntrials = max(ntrials);

intresp = zeros(nmusc,nfiles,maxntrials);
allntotal = zeros(nmusc,nfiles,maxntrials);
[b,a] = butter(5,100/(.5*newopts.samplerate),'high');  % this creates the filter to be used
for mm = 1:nmusc
    for ii = 1:nfiles
        ntrials = size(results{ii},2);
        for jj = 1:ntrials
            temp = squeeze(results{ii}(mm,jj,:));
            temp2 = filtfilt(b,a,temp);  % get rid of the DC shifts
            % find the integrated response and the number of events above threshold
            [ratio, total] = calc_integrated_response(abs(temp2),opts.baseline,opts.response);         
            [nabove, nbelow, ntotal] = calc_response_above_thresh(temp2,opts.baseline,opts.response,3);         
            intresp(mm,ii,jj) = ratio;
            allntotal(mm,ii,jj) = ntotal;
        end
    end
end
intresp(intresp == 0) = NaN;  %  any of the integrated responses that haven't been assigned, set them to NaN to flag them


%%  initializes allanswers to be the correct size from the outset

allanswers = cell(size(squeeze(intresp(1,:,:))));

%%  collect the information in allnotes - ONLY FOR SACRAL PREP

nfiles = size(allnotes,2);
header = cell(nfiles);

for ii = 1:nfiles
    if ~isempty(allnotes{ii})
        nnotes = allnotes{ii}.length;
        for jj = 1:nnotes
            note_time = allnotes{ii}.times(jj);
            note_text = allnotes{ii}.text(jj,:);
            str{ii,jj} = ['time: ' num2str(note_time) ':  ' note_text];
        end
    else
        str{ii,1} = 'no notes';
    end
    header{ii} = ['file #:' num2str(ii) ' notes                  '];
end
               
%% lets the user go through each extracted trial, look at it and at the
% calculated integrated activity and number of threshold crossings
%  NB: shows the high passed filtered data

scale = .2;   % this is the display gain
filen = 1;
display_windows = 1;  % whether to show the sample windows on the screen or not
show_notes = 0;

myts = mytimeseries;
for ii = filen ;  %1:length(results)   % iterate over the different files
    nstim = size(results{ii},2);   % iterate over the different responses in each file
    if show_notes
        options.Resize='on';
        hmsg = msgbox(str(ii,:),header{ii});
    end
    for jj = 1:nstim                
        temp = squeeze(results{ii}(:,jj,:))';
        temp2 = filtfilt(b,a,temp);  % get rid of the DC shifts
        myts.Data = squeeze(results{ii}(:,jj,:))';  % get the data for this response
%         myts.Data = temp2;  % get the data for this response
        myts.Time = (1:size(myts.Data,1))/newopts.samplerate;  % the times
        h = initialize_ts_gui(myts,[]);   % this plots the gui with the controls so you can interact with the response
        mat = [squeeze(intresp(:,ii,jj))'; squeeze(allntotal(:,ii,jj))']';  % the summary statistics       
        set(h,'Name',['file: ' num2str(ii) ', stim: ' num2str(jj) ,' time: ' num2str(stimtimes{ii}(jj))]);  % just puts a title on the figure
        set_scales(scale*ones(1,size(myts.Data,2)));  % set the display gains
        set_labels(cellstr(num2str(mat(:,1))));  % labels are the integrated response
        disp(['file: ' num2str(ii) ', stim: ' num2str(jj)]) % shows information in the command window
        disp('integrated response      nsamples above 3SD')
        disp(num2str(mat))
        if display_windows
            set_ided_times([newopts.baseline; newopts.response]/newopts.samplerate);
        end
        uiwait(h)  % wait till the user deletes the figure
        options.Resize='on';
        answer=inputdlg({'Good trial?                                         (Y/N)'},['file: ' num2str(ii) ', stim: ' num2str(jj)],1,{'Y'},options);
        allanswers(ii,jj) = answer;  % let the user judge the trial and store the answer
        close
    end
end

%%  now go through and get rid of the responses that user says are not ok


include_flags = {'Y','Spontaneous'};

for ii = 1:size(allanswers,1) 
    for jj = 1:size(allanswers,2)                
        if ~sum(strcmp(allanswers{ii,jj},include_flags))  % anything other then Y means blank out the trial
            intresp(:,ii,jj) = NaN;
            ntotal(:,ii,jj) = NaN;
        end
    end
end

%%  finally dump these values to an excel spreadsheet
spreadsheetname = 'output';
rowlabels = allnotes;  % this works for the estim files

for mm = 1:size(results{1},1)
    sheetname = ['Integrated Resp Channel #' num2str(mm)];
    values = squeeze(intresp(mm,:,:));
    [nrows,ncols] = size(values);
    outputcell = cell(nrows,ncols+1);
    cell_values = mat2cell(values,ones(nrows,1),ones(ncols,1));
    outputcell(:,2:end) = cell_values;
    outputcell(:,1) = rowlabels;

    xlswrite(spreadsheetname,outputcell,sheetname);
%     sheetname = ['# events above thresh' num2str(mm)];
%     xlswrite(spreadsheetname,squeeze(nabove(mm,:,:)),sheetname);
end

