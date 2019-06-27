%% set up the data and information
% LimbLab Path:q
% limlabPath = 'C:\Users\Pablo_Tostado\Desktop\Northwestern_University\LimbLab_Repo\limblab_analysis';
limlabPath = '/Users/josephinewallner/Desktop/N5/17-10-16';
addpath(genpath(limlabPath));

% this works, though there's a bit of a hassle with a few of the timeframes
% here - it still needs to be totally reconciled

[KINdat, KINtimes] = get_CHN_data(kinematicData,'binned');
[FIELDdat, FIELDtimes] = get_CHN_data(fielddata,'binned CAR',KINtimes);
% [FIELDdat, FIELDtimes] = get_CHN_data(fielddata,'binned raw',KINtimes);
[APdat, APtimes] = get_CHN_data(spikedata,'binned',KINtimes);
% [EMGdat, EMGtimes] = get_CHN_data(emgdata,'binned',KINtimes);
% binsize = mean(diff(KINtimes));
 binsize = 0.05;
 kinlabels = kinematicData.KinMatrixLabels;
%% choose which data to use for the decoder

inputdata = [APdat];
% [mat,pcatemp,u] = pca(FIELDdat);
% inputdata = pcatemp(:,1:50);
% outputdata = KINdat(:,end-2:end);
chartTitle = {'Limb Angle predicted from Fields'};
global xLabel; xLabel = 'Seconds'; 
global yLabel; yLabel = 'Degrees';
temp = find_joint_angles(KINdat,kinlabels);
outputdata = temp.limb;

% outputdata = EMGdat(:,[1 2 5 6]);
outputtimes = KINtimes';
% labels = kinematicData.KinMatrixLabels(:,:);
% [b,a] = butter(2,2*(binsize/2),'high');
% outputdata = filtfilt(b,a,outputdata);  

% % this is to censor the bad section of the file
% useind = 80/binsize:(KINtimes(end)/binsize);
useind = 1:(length(outputtimes)-1);

inputdata = inputdata(useind,:);
outputdata = outputdata(useind,:);
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
binnedData.cursorposbin = outputdata; %DECODING SIGNAL
binnedData.cursorposlabels = chartTitle;
binnedData.timeframe = outputtimes;

[PredSignal] = epidural_mfxval_decoding (binnedData, DecoderOptions);


% Save struct with predictions
% disp('Saving Offline Predictions...');
% an_data.wiener_offlinePredictions = PredSignal;
% 
% save([data_dir 'mat_files/' filename], 'an_data'); 

