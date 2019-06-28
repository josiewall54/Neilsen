%% Produce actual vs. predicted figures for individial decoded data set

%       Written by: Josie Wallner 2/23/2018

selection = input('Selection:');

inputChoice = resultsSummary.input(selection);
outputChoice = resultsSummary.output(selection);
numfolds = resultsSummary.numberOfFolds(selection);


%setting axes labels for actual vs. predicted graphs
switch strcmp('EMG', outputChoice)
    case 1 %EMG
        yLabel = 'mV'; 
    case 0 %Kinematics
        yLabel = 'Degrees';
end
xLabel = 'Seconds';

axesLabels.x = xLabel;
axesLabels.y = yLabel;


PlotActualVsPredictedSimple(decoderResults.actualSignals(selection),decoderResults.predictedSignals(selection),resultsSummary.chartTitles{selection},axesLabels,resultsSummary.vafValues{selection})