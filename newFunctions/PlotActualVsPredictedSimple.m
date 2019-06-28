function varargout = PlotActualVsPredictedSimple(ActualData,PredData,chartTitles,axesLabels,vafValues)

%% Summary
% This function plots actual data against predicted data, plotted in black and red lines respectively.
%       VAF values are dispayed on the graph - an average for the entire trial as
%       well as values for each fold. (The number of folds is determined when the
%       decoder is run and cannot be changed here. The number of fold is the
%       length of the trail divided by the length the testing interval)


%   VAF: the overall VAF is calculated by taking the average of the VAF values of
%           individual folds.


numPredSignals = size(PredData.preddatabin,2);
numberOfFolds = size(vafValues,1);
averageVAF = mean(vafValues,1);

yLabel = axesLabels.y;
xLabel = axesLabels.x;

timeBegin = ActualData.timeframe(1);
timeEnd = ActualData.timeframe(length(ActualData.timeframe));

    figure('name', 'Actual vs. Predicted');
   
    for i = 1:numPredSignals

        %Plot both Actual and Predicted signals
        subplot(numPredSignals,3,[3*i-2,3*i-1]);
        plot(ActualData.timeframe,ActualData.cursorposbin(:,i),'k');
        hold on;
        plot(PredData.timeframe,PredData.preddatabin(:,i),'r');
        xlim([timeBegin timeEnd])
        title(chartTitles{i});

        % adding in VAF values for each fold
        foldLengthTime = length(PredData.timeframe) / numberOfFolds;
        foldLengthData = length(PredData.preddatabin) / numberOfFolds; % this will be 5910/ 10 = 591. start: 591 * (j - 1)+1   end: 591 * (j)
        for j = 1:numberOfFolds
            lineLocation = PredData.timeframe(round(foldLengthTime * j));
            line([lineLocation lineLocation], [min(min(PredData.preddatabin(:,i)), min(ActualData.cursorposbin(:,i)))*0.9 max(max(PredData.preddatabin(:,i)),max(ActualData.cursorposbin(:,i)))*1.1], 'LineStyle', '--');
            foldSpecificVAF = vafValues(j,i);
            VAFMessage = ['VAF:' num2str(round(foldSpecificVAF*100)) '%'];
            text(lineLocation-0.9*foldLengthData*0.05, max(max(PredData.preddatabin(:,i)),max(ActualData.cursorposbin(:,i)))*1.05, VAFMessage);  
        end
        
        legend('Actual',['Predicted (Average VAF = ' num2str(round(averageVAF(i)*100)) '%)'], 'location', 'southeast');
        if i == numPredSignals
            xlabel(xLabel);
        end
        ylabel(yLabel);
        hold off;
        
        %plotting zoomed in plots; these plot a static timespan since we
        %want to look at the same time interval across plots
        subplot(numPredSignals,3,3*i);
        plot(ActualData.timeframe(48:100),ActualData.cursorposbin(48:100,i),'k');
        hold on;
        plot(PredData.timeframe(48:100),PredData.preddatabin(48:100,i),'r');              
    end
 end
