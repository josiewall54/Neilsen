%% set up the options to control the analysis 

opts.pinchChannel = 9;  % which channel has the stim marker
opts.threshold = 1.5;  % the threshold for the stim marker
% opts.labels = {'R LG','R TA','R BFP','R VL','L LG','L TA','L BFP','L VL','ticker bad', 'stim onset'};
opts.labels = {'L VL','L BFp','L TA','L LG','R VL','R BFp','R TA','R LG','ticker bad', 'stim onset'};
% opts.labels = {'L VL','L BFp','L LG','R VL','R BFp','R TA','ticker bad'};
opts.channels2use = [3 7 9 10 17];  % which channels to use from the data file
% opts.channels2use = [1 2 4:7 9];  % which channels to use from the data file
opts.min_repeat_window = .25;  % the mininum time between pulses
opts.pre_pulse_window = 2;  % the amount of time (in seconds) to extract before the pulse
opts.post_pulse_window = 10;  % the amount of time (in seconds) to extract after the pulse
opts.ext = '';
opts.display = 0;  % whether to display the identified response as they're extraced
opts.scale_factor = .25*ones(1,length(opts.channels2use));  % if you do display them, this is the gain

% opts.frameNumber = [1 200  4 5];
% opts.pulseNumber = [5001 5001 201 301 401];

opts.frameNumber = [1906 3556 5727 6406 7085 7967 1079]; % on title of the figure
opts.pulseNumber = [2512 5268 8889 10020 11155 12625 1135];  % on the LED in the figure


%% to explore a data file just scrolling
% opts.videodatafile = 'flat.avi';
opts.videodatafile = [];
opts.EMGfilename = 'Double Yellowflat';
% opts.EMGdir = 'e:\kathyALSemgs\1-19-2010'; %pwd;
opts.EMGdir = 'C:\Documents and Settings\Matt Tresch\My Documents\Data\Kathy data\1-19-2010';
%  opts.EMGfilename = 'Flat_060,080';
% opts.EMGdir = 'd:\kathyALSemgs\1-26-2010'; %pwd;
%  opts.EMGdir = 'D:\Vicki''s Pilot Study 1 2010WinterSpring\PLT9\3-11-10';
% opts.EMGdir = pwd;
% opts.ext = 'lbv';

opts.ext = '';
cd(opts.EMGdir)

create_EMG_video_gui(opts)
set_scales(.15*ones(1,length(opts.channels2use)));  % set the gains on the display to be .2

%% extract responses to pulses for a single file

filename = opts.EMGfilename;

[pulse_responses, newopts] = extract_pulses(filename,opts);
disp(newopts.PulseSamples/5000)


%%
animal = 'Single Yellow';

[onoff,textentries] = xlsread('cycle definitions.xlsx',animal);

%%

nfiles = size(onoff,2)/2;
opts.EMGfilename = [animal 'flat'];

[b,a] = butter(5,50/2500,'high');
[b2,a2] = butter(5,200/2500,'low');
for ii = 1:nfiles
%      opts.EMGdir = ['e:\kathyALSemgs\' textentries{1,ii*2-1}];
   opts.EMGdir = ['C:\Documents and Settings\Matt Tresch\My Documents\Data\Kathy data\' textentries{1,ii*2-1}];
    
   alldat = cell(1,1);
   alltimes = cell(1,1);
   if ~strcmp(textentries{2,ii*2-1},'NO FILE')
       cd(opts.EMGdir)
       sts = EMGTimeSeries(opts.EMGfilename,opts.EMGdir,['.' opts.ext]);
       sts.channels2use = opts.channels2use;

       ons = onoff(:,2*ii-1);
       offs = onoff(:,2*ii);
       ons = ons(~isnan(ons));
       offs = offs(~isnan(offs));

       alldat = cell(length(ons)-1,1);
       alltimes = cell(length(ons)-1,1);
       for jj = 1:(length(ons)-1)
           sts.nsamp1 = ons(jj)*5000 - 1000;  % take extra data to deal with edge effects
           sts.nsamp2 = ons(jj+1)*5000 + 1000; 
           sts = updateData(sts);
           dat = sts.data;
           times = sts.time;
           temp = abs(filtfilt(b,a,dat));
           temp2 = abs(filtfilt(b2,a2,temp));
           alldat{jj} = temp2(1001:(end-1000),:);
           alltimes{jj} = times(1001:(end-1000));
       end
   end
   allalldat{ii} = alldat;
end


%%

nfiles = length(allalldat);
for ii = 1:nfiles
    if isempty(allalldat{ii}{1})
        allcycles = NaN*zeros(2,500,length(opts.channels2use));
    else
        allcycles = normalize_cycles(allalldat{ii},500);
    end
    
    allallcycles{ii} = allcycles;
end

%%

nfiles = length(allalldat);
for ii = 1:nfiles
    allavg{ii} = squeeze(mean(allallcycles{ii}));
    allsd{ii} = squeeze(std(allallcycles{ii}));
end


%%  process all files in the directory - creates a separate file for each

names = dir('*.*');
nfiles = length(names);

opts.display = 0;
for ii = 1:nfiles
    if (~names(ii).isdir)  && (isempty(strfind(names(ii).name,'extracted')))
        filename = names(ii).name;
        disp(filename)
        [pulse_responses, newopts] = extract_pulses(filename,opts);
        outfilename = [filename '_extracted'];
        save(outfilename,'pulse_responses','newopts');
    end
end

%%  explore the extracted responses
sample_rate = 5000;

myts = mytimeseries;  % this is a data class which is derived from timeseries

myts.Data = pulse_responses{ii};
myts.Time = (1:size(myts.Data,1))/sample_rate;
initialize_ts_gui(myts,[])   % this plots the gui with the controls so you can interact with the response
set_scales(.2*ones(1,size(myts.Data,2)));  % set the gains on the display to be .2


%%  let's you choose a file with extracted responses, id the times on those
%  responses, then saves the times into an excel spreadsheet, with each
%  file having its own sheet

sample_rate = 5000;
xls_filename = 'test2_times';  % this is the Excel spreadsheet that will be written to

[fname, path] = uigetfile('*.mat', 'Choose file with extracted responses');

dat = load([path fname]);
pulse_responses = dat.pulse_responses;
nresponses = length(pulse_responses);
myts = mytimeseries;  % this is a data class which is derived from timeseries

alltimes = zeros(nresponses,2);
for ii = 1:nresponses  % iterate through each of the extracted responses
    myts.Data = pulse_responses{ii};
    myts.Time = (1:size(myts.Data,1))/sample_rate;
    fig = initialize_ts_gui(myts,[]);   % this plots the gui with the controls so you can interact with the response
    set_scales(.2*ones(1,size(myts.Data,2)));  % set the gains on the display to be .2
    uiwait(fig)  % wait till the user kills the window
    alltimes(ii,:) = ided_times{11};  % extract the times that have been identified
end

disp(['writing sheet: ' fname])   % write the data to the spreadsheet
xlswrite(xls_filename,alltimes,fname)

%%  command history 5/14/10

newopts
newopts.PulseSamples
size(pulse_responses)
pulse_responses
plot_matrix(pulse_response{1})
plot_matrix(pulse_responses{1})
plot_matrix(1:60001,pulse_responses{1})
plot(pulse_responses{1}(:,10))
dir
delete *.mat
dir
delete *.ps
dir
clear
load stim1_1000_extracted
who
pulse_responses
ided_times
class(ided_times)
ided_times{10}
ided_times
alltimes
help xlswrite
xls_write(xls_filename,alltimes,1)
xls_filename = 'test_times';
xls_write(xls_filename,alltimes,1)
xlswrite(xls_filename,alltimes,1)
dir *
