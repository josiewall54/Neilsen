%% Find the offset between the Vicon and the Plexon acquisition files

addpath(genpath('/Users/josephinewallner/Desktop/Lab Work/MatLab Code from Matt'));

filenames = dir(SPIKEtargetfile);
filename = strtok(filenames(1).name,'.');  % get rid of the extension for the next file 
Vicon_sync = import_plexon_analog([pwd '/'], filename, viconCh); %Import the Vicon synchronizing channel
%figure(); 
%plot(Vicon_sync.data);
% Keep only data the data when Vicon was recording:
viconChannel = find(Vicon_sync.channel == viconCh);

plxVicon = Vicon_sync.data(viconChannel,:) > 1;
plxFreq = Vicon_sync.freq(1);
if length(find(diff(plxVicon) > .5)) > 1
    disp('maybe more than one segment of Vicon acquisition in this file')
end

ind = find(plxVicon);  % find the samples when Vicon is collecting data
ViconSync.OnsetSample = ind(1);  % the Plexon sample where Vicon starts  - assuming only a single period of collection in each file
ViconSync.OnsetTime = ViconSync.OnsetSample/plxFreq;  % the time in the Plexon file when Vicon starts
ViconSync.OffsetSample = ind(end);   % the sample where the Vicon stops
ViconSync.OffsetTime = ViconSync.OffsetSample/plxFreq;  % the time where the Vicon stops
%disp(['vicon starts ' num2str(ViconSync.OnsetTime) ' seconds in Plexon file'])

%% Read in the spike data and bin their rates

filenames = dir(SPIKEtargetfile);
fileind = 1;  % vestigial?
filename = filenames(fileind).name;

%Load neural data and bin it.
spikedata = load_plexondata_spikes_v2(filename, binSize, sorted, spikeCh);
spikedata = remove_synch_spikes(spikedata); % to clean the spike artifacts. the cleaned data is stored as spikedata.channels
spikedata = align_plexon_spikes(spikedata,ViconSync);  % uses the info in ViconSync to modify the spike data in plexondata so the streams are aligned
spikedata.datatype = 'spike';

%% read in EMG data and bin them
filenames = dir(EMGtargetfile);
filename = filenames(fileind).name;

%Load EMG data and bin it.
EMG_params.binsize = binSize; EMG_params.EMG_lp = 20; EMG_params.EMG_hp = 50;  %EMG_params.bins = spikedata.aligned.spike_timeframe;
EMG_params.channels = EMGCh;
[emgdatabin, emgdata] = load_plexondata_EMG_v2(filename, EMG_params);
emgdata = align_plexon_analog(emgdata,ViconSync);
emgdata = bin_plexon_EMG(emgdata, EMG_params);
emgdata.datatype = 'emg';

%%  Read in kinematic data, express relative to hip, and bin them

[kinematicData,TreadData] = importVicon([filenameKin]);  %Import kinematics
Kinparams.viconScalingFactor = viconScalingFactor; Kinparams.referenceMarker = referenceMarker; Kinparams.ViconFreq = viconFreq;
kinematicData = zero_kinematic_data(kinematicData,Kinparams);
kinematicData = bin_kinematic_data(kinematicData,binSize); 
kinematicData.TreadData = TreadData;
kinematicData.datatype = 'kinematic';

%% read in FIELD data
filenames = dir(SPIKEtargetfile);
filename = strtok(filenames(1).name,'.');
fielddata = import_plexon_analog([pwd '/'], filename, fieldCh); %Import LFPs
fielddata = add_timeframe(fielddata);
fielddata = align_plexon_analog(fielddata,ViconSync);
fielddata.datatype = 'field';

% %% look at the FIELD data to see which channels are bad
% [Fielddat2, Fieldtimes2] = get_CHN_data(fielddata,'raw');
% % [EMGdat2, EMGtimes2] = get_CHN_data(emgdata,'raw');
% 
% ts = mytimeseries;
% ts.Time = 1:length(Fieldtimes2);
% ts.Time = (Fieldtimes2);
% % ts.Data = [Fielddat2 EMGdat2(:,5)];
% ts.Data = [Fielddat2];
% % ts.Data = [Fielddat2(:,FieldChUse)];
% % ts.Data = [Fielddat2(:,FieldChUse)];
% 
% initialize_ts_gui(ts);
% nchannels = size(Fielddat2,2); %+1;
% % set_labels(cellstr(num2str((fieldCh)')));
% set_labels(cellstr(num2str((1:32)')));
% set_scales(.5*ones(32,1))

% %%  choose which FIELd channels to process
% 
% % FieldCh2Use = [2 5 7 8 9 10 12:18 23 24 25 26 28 29 31 32];  % for N5 7-10
% % FieldCh2Use = [2 7 8 9 10 12:18 20 22:26 28 29 31 32];  % for N5 7-13
% % FieldCh2Use = 17:32; %[2 5 7 8 9 10 12:18 23 24 25 26 28 29 31 32];
% if ~exist('FieldCh2Use')
%     FieldCh2Use = 1:length(fieldCh);
% end
% 
% LFPanalysisParams.binSize = binSize;  LFPanalysisParams.data_ch = fieldCh(FieldCh2Use); LFPanalysisParams.freqBands = freqBands; 
% LFPanalysisParams.LFPwindowSize = LFPwindowSize; LFPanalysisParams.FFTwindowSize = FFTwindowSize; LFPanalysisParams.nFFT = nFFT;
% 
% fielddata = do_LFPanalysis_funct_v2(fielddata, LFPanalysisParams);

%%  this is an example for how to get data from these structures
% [Fielddat2, Fieldtimes2] = get_CHN_data(fielddata,'binned');
% [EMGdat2, EMGtimes2] = get_CHN_data(emgdata,'binned');
% [APdat, APtimes] = get_CHN_data(spikedata,'binned');
% [KINdat, KINtimes] = get_CHN_data(kinematicData,'binned');


% ts = mytimeseries;
% ts.Time = (1:length(APtimes))';
% ts.Data = [Fielddat2];
% ts.Data = [APdat; KINdat];
% initialize_ts_gui(ts);
%nchannels = size(Fielddat2,2)+1;
%set_labels(cellstr(num2str((1:nchannels)')));

%compile parameters from config file to be used downstream
LFPParams.binSize = binSize;
LFPParams.freqBands = freqBands;
LFPParams.LFPwindowSize = LFPwindowSize;
LFPParams.FFTwindowSize = FFTwindowSize;
LFPParams.nFFT = nFFT;
LFPParams.allFieldChannels = fieldCh;

save('Processed Data/DataStructures.mat','emgdata','spikedata','fielddata','kinematicData','LFPParams');




