function [R2, varargout] = epidural_mfxvalJW(binnedData, options)
%       R2                  : returns a (numFold,numSignals) array of R2 values 
%
%       binnedData          : data structure to build model from
%       options             : structure with fields:
%           dataPath            : string of the path of the data folder
%           foldlength          : fold length in seconds (typically 60)
%           fillen              : filter length in seconds (tipically 0.5)
%           UseAllInputsOption  : 1 to use all inputs, 2 to specify a neuronID file
%           PolynomialOrder     : order of the Weiner non-linearity (0=no Polynomial)
%           PredEMG, PredForce, PredCursPos, PredVeloc, Use_SD,plotflag, EMGcascade:
%                                 flags to include EMG, Force, CursPos, Velocity in the prediction model (0=no,1=yes)
%                                 also options to use State-dependent or EMG cascade dec.
%                                 Note on Use_SD      : The value of Use_SD should be set to correspond to the column index in binnedData.states
%                                 that the user wants to use. In other words, its value determines the classification method
%                                 to be used.
%           EMGcascade          : will call BuildModel twice, to
%                                 provide a neuron-to-emg decoder followed 
%                                 by an emg-to-cursorposition decoder
%           plotflag            : plot predictions after xval
%
%       Note on options: not all the fields have to be present in the
%       'option' structure provided in arguments. Those that are not will
%       be filled with the values from 'ModelBuildingDefault.m'
%
%       varargout = {vaf, mse, AllPredData, binnedData};


% default values for options:
default_options = ModelBuildingDefault();
% fill other options as provided
all_option_names = fieldnames(default_options);
for i=1:numel(all_option_names)
    if ~isfield(options,all_option_names(i))
        options.(all_option_names{i}) = default_options.(all_option_names{i});
    end
end
clear default_options all_option_names;
    
binsize = binnedData.timeframe(2) - binnedData.timeframe(1);

if mod(round(options.foldlength*1000), round(binsize*1000)) %all this rounding because of floating point errors
    disp('specified fold length must be a multiple of the data bin size');
    disp('operation aborted');
    return;
end

duration = length(binnedData.timeframe);
%nfold = floor(round(binsize*1000)*duration/(1000*options.foldlength)); % again, because of floating point errors
nfold = options.numFolds;
% numSig = getNumSigs(binnedData,options);

R2  = []; vaf = []; mse = []; vaf_fit = [];

for i=0:nfold-1
    
    % split the appropriate data into training and testing segments
    fprintf('processing xval %d of %d\n',i+1,nfold);

    
    %testDataStart = i*options.foldlength + binnedData.timeframe(1);      %move the test block from beginning of file up to the end
    binnedData.timeframe = binnedData.timeframe(1:length(binnedData.spikeratedata));
    testBinNum = round(length(binnedData.timeframe) / nfold);
    testDataStart = binnedData.timeframe(i*testBinNum + 1);
    testDataEnd = binnedData.timeframe(min(length(binnedData.timeframe),(i+1)*testBinNum));
    
    [trainData,testData] = splitBinnedData(binnedData,testDataStart,testDataEnd);
    
    %% Build model and make preds for this segment
    if options.EMGcascade
        %N2E model
        options.PredEMGs    = 1; options.PredCursPos = 0; options.PredForce = 0; options.Use_EMGs    = 0;
        N2Emodel = BuildModel(trainData, options);
        %E2C model
        options.PredEMGs    = 0; options.PredCursPos =1; options.Use_EMGs    = 1;
        E2Cmodel = BuildModel(trainData, options);
        %Pred cascade
        PredEMGs = predictSignals(N2Emodel, testData);
        PredEMGs.emgdatabin = PredEMGs.preddatabin;
        PredEMGs = rmfield(PredEMGs,'preddatabin');
        PredData = predictSignals(E2Cmodel, PredEMGs);
        fillen = 2*options.fillen -binsize;
    else        
        model = BuildModelMCT(trainData, options);
%         model = BuildModel(trainData, options);
        PredData = predictSignals(model, testData);
        fillen = options.fillen;
    end
        
    TestSigs = concatSigs(testData, options.PredEMGs, options.PredForce, options.PredCursPos, options.PredVeloc); 
%     R2(i+1,:,1) = CalculateR2(TestSigs(round(fillen/binsize):end,:),PredData.preddatabin)';
    R2   = [R2; CalculateR2(TestSigs(round(fillen/binsize):end,:),PredData.preddatabin)'];
    vaf  = [vaf; 1 - nansum( (PredData.preddatabin-TestSigs(round(fillen/binsize):end,:)).^2 ) ./ ...
                        nansum( (TestSigs(round(fillen/binsize):end,:) - ...
                        repmat(nanmean(TestSigs(round(fillen/binsize):end,:)),...
                        size(TestSigs(round(fillen/binsize):end,:),1),1)).^2 )];  
    mse  = [mse; nanmean((PredData.preddatabin-TestSigs(round(fillen/binsize):end,:)).^2)];
    PredDataFit = predictSignals(model, trainData);
    TrainSigs = concatSigs(trainData, options.PredEMGs, options.PredForce, options.PredCursPos, options.PredVeloc);
    vaf_fit  = [vaf_fit; 1 - nansum( (PredDataFit.preddatabin-TrainSigs(round(fillen/binsize):end,:)).^2 ) ./ ...
                        nansum( (TrainSigs(round(fillen/binsize):end,:) - ...
                        repmat(nanmean(TrainSigs(round(fillen/binsize):end,:)),...
                        size(TrainSigs(round(fillen/binsize):end,:),1),1)).^2 )];  
    disp(['vaf fit: ' num2str(vaf_fit(end))])
    disp(['vaf test: ' num2str(vaf(end))])

    %Concatenate predicted Data if we want to plot it later:
    %Skip this for the first fold
    if i == 0
        AllPredData = PredData;
    else
        AllPredData.timeframe = [AllPredData.timeframe; PredData.timeframe];
        AllPredData.preddatabin=[AllPredData.preddatabin;PredData.preddatabin];
    end

end %for i=1:nfold


% Plot Actual and Predicted Data
idx = false(size(binnedData.timeframe));
for i = 1:length(AllPredData.timeframe)
    idx = idx | binnedData.timeframe == AllPredData.timeframe(i);
end    

if options.PredEMGs
    binnedData.emgdatabin = binnedData.emgdatabin(idx,:);
end
if options.PredForce
    binnedData.forcedatabin = binnedData.forcedatabin(idx,:);
end
if options.PredCursPos
    binnedData.cursorposbin = binnedData.cursorposbin(idx,:);
end
if options.PredVeloc
    binnedData.velocbin = binnedData.velocbin(idx,:);
end

binnedData.timeframe = binnedData.timeframe(idx);

if options.plotflag
    ActualvsOLPred(binnedData,AllPredData,options.plotflag);
end
    
AllPredData.mfxval.R2 = R2;
AllPredData.mfxval.vaf= vaf;
AllPredData.mfxval.mse= mse;

AllPredData.mfxval.ave_R2 = mean(R2);
AllPredData.mfxval.ave_vaf = mean(vaf);
AllPredData.mfxval.ave_mse = mean(mse);

assignin('base','model',model);

% varargout{1} = AllPredData;
% varargout{2} = nfold;
varargout = {vaf, mse, AllPredData, binnedData, vaf_fit};