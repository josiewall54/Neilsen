%%Batch Decoding
%       Step 1: place files of interest in the 'SelectedData' folder
%       Step 2: create a 'DecodedData' folder
%       Step 3: initialize parent directory
%       Step 4: ensure there is a file named 'NielsenResults.xlsx' in the
%       parent directory
%       Step 4: set decoder parameters
%       Step 5: run function

%       Written by: Josie Wallner 1/19/2018
%       This function iterates through a folder of selected data, and runs
%       the files through the decoder in batch mode. Certain metrics and
%       file identifiers are appended to 'NielsenResults.xlsx', which acts
%       as a high-level database of decoder results. The decoder model,
%       actual data, and predicted data are stored in the 'DecodedData'
%       folder with one overarching .mat folder for each run of this
%       function. 
%% Set directories
ratDataDirectory = '/Users/josephinewallner/Desktop/LabWork/RatData';
SelectedData = [ratDataDirectory '/SelectedData'];

%% Set decoder parameters
DecoderOptions.PredEMGs = 0;             % Predict EMGs (bool)
DecoderOptions.PredCursPos = 1;          % Predict kinematic data (bool)
DecoderOptions.PolynomialOrder = 0;      % Order of Wiener cascade - 0 1 for linear
DecoderOptions.foldlength = 60;          % Duration of folds (seconds)
DecoderOptions.fillen = 0.5;             % Filter Length: Spike Rate history used to predict a given data point (in seconds). Usually 500ms.
DecoderOptions.UseAllInputs = 1;
DecoderOptions.numFolds = 10;
DecoderOptions.plotflag = 0;
%% Loop through files in SelectedData folder
cd(SelectedData);
folderInfo = dir('*.mat');
filenames = {folderInfo.name};

%read latest batch_id from 'NielsenResults.xlsx'
cd(ratDataDirectory);
batchIds = xlsread('NielsenResults.xlsx','A:A');
latestBatchId = max(batchIds);
lastRow = length(batchIds) + 2;

currentBatchId = latestBatchId + 1;
firstInsertRow = lastRow + 1;
lastInsertRow = lastRow + 3*length(filenames) + 1; %4 for each actual entry, and then a row for the title row

%% iterate through files
for fileNum=1:length(filenames)
    %     %this will store:
    %     %       1. numeric values into the results excel sheet
    %     %       2. .mat structures that can be run through the evaluation
    %     %       function later on
    %     %       --- this means the DecoderWrapper function needs to return two
    %     %       objects: a vector of values that line up with
    %     %       NielsenResults.xlsx, and a .mat structure that contains
    %     %       everything necessary to plot the graphs and recreate the
    %     %       decoder
    cd(SelectedData);
    load(filenames{fileNum}); %load in selected data
    fileMetaData = strsplit(standardFilename,'_');

    axesLabels.x = 'Seconds'; %true for every case

    %format kinematic data
    kinematicData = [];
    kinematicDataTemp = struct2cell(SelectedKinematicData.kinmeasures);
    for j = 1:length(kinematicDataTemp)
        kinematicData = horzcat(kinematicData,kinematicDataTemp{j,1});
    end

        %adjust labels
        axesLabels.y = 'Degrees';
        labels = SelectedKinematicData.labels;
        for i = 1:size(labels,2) chartTitle{i} = strcat(deblank(labels(:,i)),' predicted from Spikes'); end
        
        %run decoder for Spikes / Kinematics
        [PredSignal(2*(fileNum-1)+1),ActualData(2*(fileNum-1)+1)] = DecoderWrapperJ(timeframe,SelectedSpikeData,kinematicData,DecoderOptions,labels); %Kinematics from Spikes
            results.numberOfFolds{2*(fileNum-1)+1} = DecoderOptions.numFolds;
            results.VAF{2*(fileNum-1)+1} = mean(mfxval_vaf,1);
            results.stdVAF{2*(fileNum-1)+1} = std(std(mfxval_vaf));
            results.chartTitles{2*(fileNum-1)+1} = chartTitle;
            results.input{2*(fileNum-1)+1} = 'Spikes';
            results.output{2*(fileNum-1)+1} = 'Kinematic';
            results.model{2*(fileNum-1)+1} = model;
            results.chartTitles{2*(fileNum-1)+1} = chartTitle;
            results.vafValues{2*(fileNum-1)+1} = mfxval_vaf;
            
        %adjust lables    
        for i = 1:size(labels,2) chartTitle{i} = strcat(deblank(labels(:,i)), ' predicted from Fields'); end
        %run decoder for Fields / Kinematics
        [PredSignal(2*(fileNum-1)+2),ActualData(2*(fileNum-1)+2)] = DecoderWrapperJ(timeframe,SelectedFieldData.data,kinematicData,DecoderOptions,labels);
            results.numberOfFolds{2*(fileNum-1)+2} = DecoderOptions.numFolds;
            results.VAF{2*(fileNum-1)+2} = mean(mfxval_vaf,1);
            results.stdVAF{2*(fileNum-1)+2} = std(std(mfxval_vaf));
            results.chartTitles{2*(fileNum-1)+2} = chartTitle;
            results.input{2*(fileNum-1)+2} = 'Fields';
            results.output{2*(fileNum-1)+2} = 'Kinematic';
            results.model{2*(fileNum-1)+2} = model;
            results.chartTitles{2*(fileNum-1)+2} = chartTitle;
            results.vafValues{2*(fileNum-1)+2} = mfxval_vaf;
        

        %these values are the same for one file
        results.trialDate(2*(fileNum-1)+1:2*(fileNum-1)+2) = {fileMetaData{2}};
        results.rat(2*(fileNum-1)+1:2*(fileNum-1)+2) = {fileMetaData{1}};
        results.trialType(2*(fileNum-1)+1:2*(fileNum-1)+2) = {fileMetaData{3}};
        
end

%% Add current batchId and date to each result row, to identify files processed together
cd(ratDataDirectory);

insertRange = strcat('A', num2str(firstInsertRow), ':N', num2str(lastInsertRow));


date = datetime('today');
numberDate = year(date)*10000 + month(date)*100 + day(date);

results.batchId = ones(2*length(filenames),1) * currentBatchId;
results.batchDate = ones(2*length(filenames),1) * numberDate;


resultsTable = table(...
        results.batchId...
        ,results.batchDate...
        ,results.trialDate'...
        ,results.rat'...
        ,results.trialType'...
        ,results.VAF'...
        ,results.stdVAF'...
        ,results.input'...
        ,results.output'...
        ,results.numberOfFolds'...
        , 'VariableNames'...
        ,{'BatchId','BatchDate','TrialDate','Rat','TrialType','VAF','StdVAF','Input','Output','NumberOfFolds',});
    
    
writetable(resultsTable,'NielsenResults.xlsx','Sheet','Insert','Range',insertRange);

decoderResults.date = date;
decoderResults.batchId = currentBatchId;
decoderResults.predictedSignals = PredSignal;%add above in for loop
decoderResults.actualSignals = ActualData;%add above in for loop
resultsSummary = results;

resultsFilename = strcat('BatchResults_', string(decoderResults.date), '_', string(decoderResults.batchId),'.mat');
%resultsFilenameFull = ['DecoderResultSets/' resultsFilename];

resultsFilenameFull = strcat('DecoderResultSets/',resultsFilename);

save(resultsFilenameFull, 'decoderResults','resultsSummary');
