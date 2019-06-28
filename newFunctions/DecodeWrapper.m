%% choose which data to use for the decoder
inputChoice = input('Input (Spikes(1) or Fields(2)):'); %this can be Spikes or Fields
outputChoice = input('Output (EMG(3) or Kinematics(4)):');%this can be EMG or Kinematics
numfolds = input('Enter the number of folds: ');

switch inputChoice
    case 1 %Spikes
        inputdata = SelectedSpikeData;
        plotHeatMap = '1';
    case 2 %Fields
        inputdata = SelectedFieldData;
        %inputdata = SelectedFieldDataAvgs;
        %inputdata = SelectedFieldDataSpliced;
        plotHeatMap = '0';
end

switch outputChoice
    case 3 %EMG
        outputdata = SelectedEMGData;
        labels = values(EMGChannelNames);
        for i = 1:size(SelectedChannels.EMG,2)
            channelName = deblank(labels(SelectedChannels.EMG(1)));
            switch inputChoice
                case 1 %Spikes
                    chartTitle(i) = strcat('EMG predicted from Spikes (',deblank(labels(SelectedChannels.EMG(i))),')');
                case 2 %Fields
                    chartTitle(i) = strcat('EMG predicted from Spikes (',deblank(labels(SelectedChannels.EMG(i))),')');
            end
        end
    case 4 %Kinematics
%         [Kinmetric,labels] = find_joint_angles(finalDataSelections.binnedKinematicData,finalDataSelections.kinematicLabels);
%         KINtemp = struct2cell(Kinmetric);
        outputdata = [];
        outputdatatemp = struct2cell(SelectedKinematicData.kinmeasures); %remove "Spliced"
        for i = 1:length(outputdatatemp)
            outputdata = horzcat(outputdata,outputdatatemp{i,1});
        end
        labels = SelectedKinematicData.labels;
        for i = 1:size(labels,1)
            switch inputChoice
                case 1
                    chartTitle{i} = [deblank(labels(i,:)) ' predicted from Spikes'];
                case 2
                    chartTitle{i} = [deblank(labels(i,:)) ' predicted from Fields'];
            end
        end       
end

%setting axes labels for actual vs. predicted graphs
switch outputChoice
    case 3 %EMG
        yLabel = 'mV'; 
    case 4 %Kinematics
        yLabel = 'Degrees';
end
xLabel = 'Seconds';

axesLabels.x = xLabel;
axesLabels.y = yLabel;

%% commented to run only the freemotion data
outputtimes = timeframe;
% % % % % % % useind = 1:(length(outputtimes)-1);
% % % % % % % 
% % % % % % % inputdata = inputdata(useind,:);
% % % % % % % outputtimes = outputtimes(useind);
%% do the decoding
ninputs = size(inputdata, 2);   % the number of channels in the input

% Set decoding parameters and predict kinematics
DecoderOptions.PredEMGs = 0;             % Predict EMGs (bool)
DecoderOptions.PredCursPos = 1;          % Predict kinematic data (bool)
DecoderOptions.PolynomialOrder = 0;      % Order of Wiener cascade - 0 1 for linear
DecoderOptions.foldlength = 30;          % Duration of folds (seconds)
DecoderOptions.fillen = 0.5;             % Filter Length: Spike Rate history used to predict a given data point (in seconds). Usually 500ms.
DecoderOptions.UseAllInputs = 1;
DecoderOptions.numFolds = numfolds;
DecoderOptions.plotflag = 0;

% These parameters are standard in the LAB when using the Wiener decoder code:
binnedData.spikeratedata = inputdata;
binnedData.neuronIDs = [ [1:ninputs]' zeros(ninputs, 1)];
binnedData.cursorposlabels = labels;
binnedData.timeframe = outputtimes;
%% commented only for freemotion data
% % % % % % % % outputdata = outputdata(useind,:);
%%
binnedData.cursorposbin = outputdata; %DECODING SIGNAL
[PredSignal,ActualData] = epidural_mfxval_decoding(binnedData, DecoderOptions);
disp(PredSignal.mfxval.ave_vaf);    
    
    
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
% if plotHeatMap == '0'
% else
%     APdat2 = finalDataSelections.binnedSpikeData;
%     Tdat = APdat2(31*20:36*20,:)';
%     minval = min(Tdat,[],2);
%     maxval = max(Tdat,[],2);
%     normdata =[];
%     for ii = 1:size(Tdat,1)
%         mintdat = Tdat(ii,:)-minval(ii);
%         normdat = mintdat/maxval(ii);
%         for iii=1:size(Tdat,2)
%         if normdat(1,iii)<0.4
%             normdat(1,iii) = 0;
%         end
%         end
%         normdata = vertcat(normdat,normdata);
%     end
%   
%     figure();
%     imagesc([31:0.05:36], [], normdata);title('N8 no obstacle multiunit modulation');
%     colormap(jet);
% end
%save('DecoderResults.mat','vaf','mse','R2','mfxval_mse','mfxval_R2','mfxval_vaf','mfxval_vaf_fit');
%% Save data for future reference and plotting 
%save('test.mat','ActualData','PredSignal','mfxval_vaf','chartTitle','axesLabels')

%% Plot Actual & predicted data
%PlotActualVsPredictedSimple(ActualData,PredSignal,chartTitle,axesLabels,mfxval_vaf)
PlotActualVsPredicted(ActualData,PredSignal,chartTitle,numfolds)


%% replacing NaN with average values of each signal
% SelectedFieldDataAvgs = zeros(size(SelectedFieldData));
% 
% for i = 1:size(SelectedFieldData,2)
%     averageSignal = nanmean(SelectedFieldData(:,i));
%     newChannelData = SelectedFieldData(:,i);
%     newChannelData(find(isnan(newChannelData))) = averageSignal;
%     SelectedFieldDataAvgs(:,i) = newChannelData;
% end
% 
% 
% %% splicing together sections (getting rid of NaN)
% 
% lengthOfDataField = size(SelectedFieldData(:,1)) - size(find(isnan(SelectedFieldData(:,1))));
% lengthOfDataKin = size(SelectedKinematicData.kindata(:,1)) - size(find(isnan(SelectedFieldData(:,1))));
% SelectedFieldDataSpliced = zeros(lengthOfDataField(1),size(SelectedFieldData,2));
% SelectedKinematicDataSpliced = SelectedKinematicData;
% SelectedKinematicDataSpliced.kindata = zeros(lengthOfDataKin(1),size(SelectedKinematicData,2));
% 
% 
% for i = 1:size(SelectedFieldData,2)
%     newChannelDataField = SelectedFieldData(setdiff(1:end,find(isnan(SelectedFieldData(:,i)))),i);
%     SelectedFieldDataSpliced(:,i) = newChannelDataField;
% end
% 
% 
% SelectedKinematicDataSpliced.kinmeasures.ankle = zeros(lengthOfDataKin(1),1);
% SelectedKinematicDataSpliced.kinmeasures.ankle = SelectedKinematicData.kinmeasures.ankle(setdiff(1:end,find(isnan(SelectedFieldData(:,1)))),1);
% 
% SelectedKinematicDataSpliced.kinmeasures.limbfoot = zeros(lengthOfDataKin(1),1);
% SelectedKinematicDataSpliced.kinmeasures.limbfoot = SelectedKinematicData.kinmeasures.limbfoot(setdiff(1:end,find(isnan(SelectedFieldData(:,1)))),1);
% 
% SelectedKinematicDataSpliced.kinmeasures.hip = zeros(lengthOfDataKin(1),1);
% SelectedKinematicDataSpliced.kinmeasures.hip = SelectedKinematicData.kinmeasures.hip(setdiff(1:end,find(isnan(SelectedFieldData(:,1)))),1);
% 
% SelectedKinematicDataSpliced.kinmeasures.ankle = zeros(lengthOfDataKin(1),1);
% SelectedKinematicDataSpliced.kinmeasures.ankle = SelectedKinematicData.kinmeasures.ankle(setdiff(1:end,find(isnan(SelectedFieldData(:,1)))),1);
% 
% SelectedKinematicDataSpliced.kinmeasures.knee = zeros(lengthOfDataKin(1),1);
% SelectedKinematicDataSpliced.kinmeasures.knee = SelectedKinematicData.kinmeasures.knee(setdiff(1:end,find(isnan(SelectedFieldData(:,1)))),1);
% 
% SelectedKinematicDataSpliced.kinmeasures.toeheight = zeros(lengthOfDataKin(1),1);
% SelectedKinematicDataSpliced.kinmeasures.toeheight = SelectedKinematicData.kinmeasures.toeheight(setdiff(1:end,find(isnan(SelectedFieldData(:,1)))),1);
% 
% 
% 
% 


