%% Create Final Data Structures

%Steps
%   1. Plot EMG channels and pick the good ones - store these in
%   goodEmgChannels
%   2. Plot field channels and pick the bad ones -
%   store the offset in goodFieldChannels


%% Kinematic Data
%%%%% Select the desired kinematic measures
[KINdat, KINtimes] = get_CHN_data(kinematicData,'binned');
[Kinmetric,labels] = find_joint_angles(KINdat,kinematicData.KinMatrixLabels);
SelectedKinematicData.kindata = KINdat;
SelectedKinematicData.kinmeasures = Kinmetric;
for i = 1:size(labels,1)
    tempLabels{i} = strtrim(labels(i,:));
end
SelectedKinematicData.labels = tempLabels;
timeframe = kinematicData.Binnedtimeframe;
timeframe = timeframe';

%% View the emg data
ts = mytimeseries;
ts.Time = 1:length(emgdata.data);
ts.Data = emgdata.data;
initialize_ts_gui(ts);
EMGChLabels = emgdata.channelNames;
set_labels(EMGChLabels);
[emgch2use] = input('Select the good emg channel as [1,2,..]: '); %% choose which emg channels to process
SelectedEMGChannels = emgdata.data(:,emgch2use);
SelectedEMGChannelLabels = EMGChLabels(emgch2use);


%% Filter the selected EMG channels
EMGSelected_params.binsize = 0.05; EMGSelected_params.EMG_lp = 20; EMGSelected_params.EMG_hp = 50;  %EMGSelected_params.bins = ViconSync.binedges;
EMGSelected_params.channels = emgch2use; EMGSelected_params.bins = LFPParams.bins;

SelectedFilteredEMGData.freq = emgdata.freq;
SelectedFilteredEMGData.timeframe = emgdata.timeframe;
SelectedFilteredEMGData.channel = length(emgch2use);

emgsamplerate = emgdata.freq;

[bh,ah] = butter(3, EMGSelected_params.EMG_hp*2/emgsamplerate, 'high'); %highpass filter params
[bl,al] = butter(3, EMGSelected_params.EMG_lp*2/emgsamplerate, 'low');  %lowpass filter params

ii = 1; 
while ii<length(emgch2use)+1
    rawEMG = double(SelectedEMGChannels(:,ii));
    averageSignal = mean(rawEMG);
    tempEMG = filtfilt(bh,ah,rawEMG); %highpass filter
    tempEMG = abs(tempEMG); %rectify     
     %figure();plot(tempEMG);
     %title(strcat('Original EMG of selected channel: ',EMGChLabels(emgch2use(ii))));

    
    numStdDevs = input('Enter the threshold multiple for this EMG chanel: '); 
    %stdDev = std(tempEMG); %compute stdev based on filtered & rectified emg signals
    stdDev = std(rawEMG); %compute stdev based on raw emg signals
    %threshold = NSDVal(ii)*stdDev + mean(tempEMG);
    threshold = numStdDevs * stdDev;
    cutoffTop = averageSignal + threshold;
    cutoffBottom = averageSignal - threshold;

    %timesToRemove = find(tempEMG > threshold); %for computing based on filtered & rectified data
    timesToRemove = find(rawEMG > cutoffTop | rawEMG < cutoffBottom); %compute stdev based on raw emg signals
    % Plot the markers on the removedTimes
%     marker = horzcat(timesToRemove,2*ones(length(timesToRemove),1));
%     plot(tempEMG);
%     title(strcat('Removed times of Selected EMG Channel: ',EMGChLabels(emgch2use(ii))));
%     hold on; scatter(marker(:,1),marker(:,2),'r','*');


    rawEMG(timesToRemove) = averageSignal;
    cleanEMG = rawEMG;
    
    % Plot the rawEMG with averageSignal
%     plot(rawEMG);
%     hold on;
%     hline = refline([0 averageSignal + threshold]);
%     hline.Color = 'k';

%     hold on; plot(tempEMG1);
%     title(strcat('Filtered Selected EMG Channel: ',EMGChLabels(emgch2use(ii))));
   
    SelectedFilteredEMGData.data(:,ii) = cleanEMG; %low;
%     hold on; plot(SelectedFilteredEMGData.data(:,ii));% Plot low pass filtered data
    
    ii = ii+1;
end

% %look at emg signals after "cleaning"
% ts = mytimeseries;
% ts.Time = 1:length(SelectedFilteredEMGData.data);
% ts.Data = SelectedFilteredEMGData.data;
% initialize_ts_gui(ts);

SelectedFilteredEMGData.freq = emgdata.freq;
SelectedFilteredEMGData.timeframe = emgdata.timeframe;
SelectedFilteredEMGData.channel = 1:length(emgch2use);
SelectedEMGBinnedData = bin_plexon_EMG(SelectedFilteredEMGData, EMGSelected_params);
OriginalEMG = bin_plexon_EMG(emgdata, EMGSelected_params); %bin original emg data for future reference

%% Create final emg data structure
SelectedEMGData.data = SelectedEMGBinnedData.binned.data; %assign filtered, binned emg data
SelectedEMGData.dataOri = OriginalEMG.binned.data; %assign original, binned emg data
SelectedEMGData.timeframe = SelectedEMGBinnedData.binned.timeframe;
SelectedEMGData.ch2Use = emgch2use;
SelectedEMGData.NSD = numStdDevs;
SelectedEMGData.removedArtifactTimes = timesToRemove;

%%%% to synchronize (needs to be debugged)
req_times = timeframe';
if length(req_times > 2)
    req_times = [req_times(1) req_times(end)];
end
outdata = SelectedEMGData.data;
outtimes = SelectedEMGData.timeframe; 


%%%%%%% to synchronize continued (double check and combine with above)
ind = find((outtimes >= req_times(1)) & (outtimes <= req_times(2)));
SelectedEMGData.data = outdata(ind,:);
SelectedEMGData.timeframe = outtimes(ind);

%% Process Field Channels

%Plot Field Channels
ts = mytimeseries;
ts.Time = fielddata.timeframe;
ts.Data = fielddata.data';
nchan = size(ts.Data,2);
initialize_ts_gui(ts);
nchannels = size(fielddata.data',2);
set_labels(cellstr(num2str((1:nchan)')));
set_scales(.5*ones(nchan,1));

%select bad field channels
[badchan] = input('Select the bad field channels as [1,2..]: ');
FieldCh2Use = setdiff(1:32,badchan);
LFPParams.data_ch = 1:length(FieldCh2Use);

%remove common average from good field channels
fielddata.data = fielddata.data(FieldCh2Use,:);
fielddata = do_LFPanalysis_funct_v2(fielddata, LFPParams);
[FIELDdata, FIELDtimes] = get_CHN_data(fielddata,'binned CAR',timeframe');
binnedFieldData = FIELDdata;

[fielddata.data,fielddata.oridata, removedFieldBins, nsd] = remove_field_artifacts(binnedFieldData,10,3); 

SelectedFieldData.data = fielddata.data';

SelectedFieldData.dataOri = fielddata.oridata;
SelectedFieldData.removedArtifactTimes = removedFieldBins;
SelectedFieldData.fieldCh2Use = FieldCh2Use;

%% Process Spike Data
[APdat, APtimes] = get_CHN_data(spikedata,'binned',timeframe');
[filtered_data,ori_spikedata, removedSpikeBins, nsd] = filter_spikes(APdat); % specify nsd value as input if required
SelectedSpikeDataStruct.cleanData = filtered_data;
SelectedSpikeDataStruct.NSD = nsd;
SelectedSpikeDataStruct.removedSpikeBins = removedSpikeBins;
SelectedSpikeData = filtered_data(:,FieldCh2Use);% remove spike channels for which fields are not good

% % to plot the data before and after filtering
% removed_bins_are = round(removedSpikeBins/20);
% nchan = size(APdat,2);

%% Save Selected Data
cd('/Users/josephinewallner/Desktop/LabWork/RatData/SelectedData');

save(strcat(standardFilename,'_s','.mat'),'SelectedEMGData','SelectedEMGChannelLabels','SelectedFieldData','SelectedSpikeData','SelectedKinematicData','timeframe','standardFilename');