%% set up the data and information
% LimbLab Path:
% limlabPath = 'C:\Users\Pablo_Tostado\Desktop\Northwestern_University\LimbLab_Repo\limblab_analysis';
% limlabPath = '/Users/josephinewallner/Desktop/Lab Work/Rat Data/N8/17-10-20';
plexonFileName = fileMetaData.plexonFileName;
% addpath(genpath(limlabPath));


% this works, though there's a bit of a hassle with a few of the timeframes
% here - it still needs to be totally reconciled


KINdat = finalDataSelections.binnedKinematicData;
FIELDdat = finalDataSelections.binnedFieldDataClean; %this is using the field data after artifact-removal
APdat = finalDataSelections.binnedSpikeData;
EMGdat = finalDataSelections.binnedEMGData;
outputtimes = finalDataSelections.timeframe';



%[KINdat, KINtimes] = get_CHN_data(kinematicData,'binned');
%[FIELDdat, FIELDtimes] = get_CHN_data(fielddata,'binned CAR',KINtimes);
% [FIELDdat, FIELDtimes] = get_CHN_data(fielddata,'binned raw',KINtimes);
%[APdat, APtimes] = get_CHN_data(spikedata,'binned',KINtimes); 
%[EMGdat, EMGtimes] = get_CHN_data(emgdata,'binned',KINtimes);
 %binsize = mean(diff(KINtimes));
 binsize = 0.05;
%kinlabels = kinematicData.KinMatrixLabels;
kinlabels = finalDataSelections.kinematicLabels;
%% choose which data to use for the decoder

inputChoice = input('Input (Spikes(1) or Fields(2)):'); %this can be Spikes or Fields
outputChoice = input('Output (EMG(3) or Kinematics(4)):');%this can be EMG or Kinematics

switch inputChoice
    case 1 %Spikes
        inputdata = [APdat];  
    case 2 %Fields
        inputdata = FIELDdat(:,finalDataSelections.goodFieldChannels);
end
chartTitle = {};
switch outputChoice
    case 3 %EMG
        EMGChannels = finalDataSelections.goodEmgChannels;
        outputdata = EMGdat(:,EMGChannels);
        [n,names] = plx_adchan_names(plexonFileName);
        for i = 1:size(EMGChannels,2)
            switch inputChoice
                case 1
                    chartTitle{i} = ['EMG predicted from Spikes (' deblank(names(49 + EMGChannels(i),:)) ')'];
                case 2
                    chartTitle{i} = ['EMG predicted from Fields (' deblank(names(49 + EMGChannels(i),:)) ')'];
            end
        end
        chartTitle{end+1} = [plexonFileName(1:end-4) '_EMGFoldSpecificVAFs.mat'];     
    case 4 %Kinematics
        [Kinmetric,labels] = find_joint_angles(KINdat,kinlabels);
        KINtemp = struct2cell(Kinmetric);
        outputdata = [];
        for i = 1:length(KINtemp)
            outputdata = horzcat(outputdata,KINtemp{i,1});
        end
        for i = 1:length(KINtemp)
            switch inputChoice
                case 1
                    chartTitle{i} = [deblank(labels(i,:)) ' predicted from Spikes'];
                case 2
                    chartTitle{i} = [deblank(labels(i,:)) ' predicted from Fields'];
            end
            %chartTitle{i} = [strcat(labels(i),' kinemtics predicted from Spikes')];
        end
%         chartTitle{end+1} = [plexonFileName(1:end-4) '_EMGFoldSpecificVAFs.mat'];
end

%setting axes labels for actual vs. predicted graphs
global yLabel;
switch outputChoice
    case 3 %EMG
        yLabel = 'mV'; 
    case 4 %Kinematics
        yLabel = 'Degrees';
end
global xLabel; xLabel = 'Seconds';

%outputtimes = KINtimes';
% labels = kinematicData.KinMatrixLabels(:,:);
% [b,a] = butter(2,2*(binsize/2),'high');
% outputdata = filtfilt(b,a,outputdata);  

% % this is to censor the bad section of the file
% useind = 80/binsize:(KINtimes(end)/binsize);
useind = 1:(length(outputtimes)-1);

inputdata = inputdata(useind,:);
outputtimes = outputtimes(useind);

%% do the decoding
ninputs = size(inputdata, 2);   % the number of channels in the input

% Set decoding parameters and predict kinematics

% Mandatory fields to specify the signal to decode 
DecoderOptions.PredEMGs = 0;             % Predict EMGs (bool)
DecoderOptions.PredCursPos = 1;          % Predict kinematic data (bool)

DecoderOptions.PolynomialOrder = 0;      % Order of Wiener cascade - 0 1 for linear
DecoderOptions.foldlength = 30;          % Duration of folds (seconds)
DecoderOptions.fillen = 0.5;             % Filter Length: Spike Rate history used to predict a given data point (in seconds). Usually 500ms.
DecoderOptions.UseAllInputs = 1;

% These parameters are standard in the LAB when using the Wiener decoder code:
binnedData.spikeratedata = inputdata;
binnedData.neuronIDs = [ [1:ninputs]' zeros(ninputs, 1)];
binnedData.cursorposlabels = chartTitle;
binnedData.timeframe = outputtimes;

outputdata = outputdata(useind,:);
binnedData.cursorposbin = outputdata; %DECODING SIGNAL
[PredSignal] = epidural_mfxval_decoding (binnedData, DecoderOptions);
    
    
    
% % if size(outputdata,2)>1
% %     for metrics = 1:length(KINtemp)
% %         outputdata1 = outputdata(useind,metrics);
% %         binnedData.cursorposbin = outputdata1; %DECODING SIGNAL
% %         [PredSignal] = epidural_mfxval_decoding (binnedData, DecoderOptions);
% %     end
% % else
% %     outputdata = outputdata(useind,:);
% %     binnedData.cursorposbin = outputdata; %DECODING SIGNAL
% %     [PredSignal] = epidural_mfxval_decoding (binnedData, DecoderOptions);
% % end


%%
%%%%%%%%%%%%%% Plot Heat map of spike data
Tdat = APdat;
temp1 = quantile(Tdat,0.05);
temp2 = quantile(Tdat,0.95);
range = [min(min(temp1)) max(max(temp2))];
 
for ii = 1:size(Tdat,2)
    indices = find(Tdat(:,ii)<temp1(ii));
    Tdat(indices) = temp1(ii);
end

Tdat = Tdat-ones(size(Tdat,1),1)*temp1;

for ii = 1:size(Tdat,2)
    indices = find(Tdat(:,ii)>temp2(ii));
    Tdat(indices) = temp2(ii);
end
figure();
H = subplot(1,2,1);imagesc([0:600], [], Tdat',range);title('Binned Spike Data');xlabel('seconds');ylabel('Channels');
H = subplot(1,2,2);imagesc([500:508], [], Tdat(10000:10160,:)',range);title('Binned Spike Data');xlabel('seconds');ylabel('Channels');
colormap(jet);

save('DecoderResults.mat','vaf','mse','R2','mfxval_mse','mfxval_R2','mfxval_vaf','mfxval_vaf_fit');

