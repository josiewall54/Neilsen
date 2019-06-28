function varargout = PlotActualVsPredicted(ActualData,PredData,labels,numberOfFolds)
    
numPredSignals = size(PredData.preddatabin,2);
vaf = 1 - nansum( (PredData.preddatabin-ActualData.cursorposbin).^2 ) ./ nansum((ActualData.cursorposbin - repmat(nanmean(ActualData.cursorposbin),size(ActualData.cursorposbin,1),1)).^2 );
yLabel = 'Degrees';
xLabel = 'Seconds';

    h = figure('name', 'Actual vs. Predicted');
    for i = 1:numPredSignals

        %results(i).label = PredData.outnames{i};

        %Plot both Actual and Predicted signals
        subplot(numPredSignals,3,[3*i-2,3*i-1]);
        plot(ActualData.timeframe,ActualData.cursorposbin(:,i),'k');
        hold on;
        plot(PredData.timeframe,PredData.preddatabin(:,i),'r');
        title(labels(i));

        % adding in VAF values for each fold
        foldLengthTime = length(PredData.timeframe) / numberOfFolds;
        foldLengthData = length(PredData.preddatabin) / numberOfFolds; % this will be 5910/ 10 = 591. start: 591 * (j - 1)+1   end: 591 * (j)
        for j = 1:numberOfFolds;
            lineLocation = PredData.timeframe(round(foldLengthTime * j));
            line([lineLocation lineLocation], [min(min(PredData.preddatabin(:,i)), min(ActualData.cursorposbin(:,i)))*0.9 max(max(PredData.preddatabin(:,i)),max(ActualData.cursorposbin(:,i)))*1.1], 'LineStyle', '--');
            foldStart = foldLengthData * (j-1) + 1;
            foldEnd = foldLengthData * j;
            foldSpecificVAF = 1 - nansum( (PredData.preddatabin(foldStart:foldEnd,i)-ActualData.cursorposbin(foldStart:foldEnd,i)).^2 )./ nansum( (ActualData.cursorposbin(foldStart:foldEnd,i) - repmat(nanmean(ActualData.cursorposbin(foldStart:foldEnd,i)),size(ActualData.cursorposbin(foldStart:foldEnd,i),1),1)).^2 );
            VAFMessage = ['VAF:' num2str(round(foldSpecificVAF*100)) '%'];
            text(lineLocation-0.9*foldLengthData*0.05, max(max(PredData.preddatabin(:,i)),max(ActualData.cursorposbin(:,i)))*1.05, VAFMessage);  
            %results(i).data(j) = foldSpecificVAF;
        end
        legend('Actual',['Predicted (Average VAF = ' num2str(round(vaf(i)*100)) '%)'], 'location', 'southeast');
        if i == numPredSignals
            xlabel(xLabel);
        end
        ylabel(yLabel);
        hold off;

        subplot(numPredSignals,3,3*i);
        plot(ActualData.timeframe(4848:5000),ActualData.cursorposbin(4848:5000,i),'k');
        hold on;
        plot(PredData.timeframe(4848:5000),PredData.preddatabin(4848:5000,i),'r');              
    end

    %save(['Results/' PredData.outnames{length(PredData.outnames)}], 'results');
 end
