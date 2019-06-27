function varargout = ActualvsOLPred(ActualData, PredData, varargin)

    global xLabel;
    global yLabel;
            
    if nargin >2
        plotflag = varargin{1};
        dispflag = 0;
        if nargin>3
            dispflag = varargin{2};
        end
    else
        plotflag = 0;
        dispflag = 0;
    end

    numPredSignals = size(PredData.preddatabin,2);
    
    %match data with timeframes
    idx = false(size(ActualData.timeframe));
    for i = 1:length(PredData.timeframe)
        idx = idx | ActualData.timeframe == PredData.timeframe(i);
    end   
    
    ActSignalsTrunk = zeros(length(nonzeros(idx))       ,numPredSignals);
    ActSignalsFull  = zeros(length(ActualData.timeframe),numPredSignals);
    
    for i=1:numPredSignals
        if isfield(ActualData,'emgdatabin')
            if ~isempty(ActualData.emgdatabin)
                emg_i = strcmp(ActualData.emgguide,PredData.outnames(i));
                if any(emg_i)
                    ActSignalsTrunk(:,i) = ActualData.emgdatabin(idx,emg_i);
                    ActSignalsFull (:,i) = ActualData.emgdatabin(:,emg_i);
                end
            end
        end
        if isfield(ActualData,'forcedatabin')
            if ~isempty(ActualData.forcedatabin)
                force_i = strcmp(ActualData.forcelabels,PredData.outnames(i));
                if any(force_i)
                    ActSignalsTrunk(:,i) = ActualData.forcedatabin(idx,force_i);
                    ActSignalsFull (:,i) = ActualData.forcedatabin(:,force_i);
                end
            end
        end
        if isfield(ActualData,'cursorposbin')
            if ~isempty(ActualData.cursorposbin)
                %curs_i = strcmp(ActualData.cursorposlabels,PredData.outnames(i));
                %if any(curs_i)
                   % ActSignalsTrunk(:,i) = ActualData.cursorposbin(idx,curs_i);
                    %ActSignalsFull (:,i) = ActualData.cursorposbin(:,curs_i);
                    ActSignalsFull = ActualData.cursorposbin;
                    ActSignalsTrunk = ActualData.cursorposbin;
               % end
            end
        end

        if isfield(ActualData,'velocbin')
            if ~isempty(ActualData.velocbin)
                vel_i = strcmp(ActualData.veloclabels,PredData.outnames(i));
                if any(vel_i)
                    ActSignalsTrunk(:,i) = ActualData.velocbin(idx,vel_i);
                    ActSignalsFull (:,i) = ActualData.velocbin(:,vel_i);
                end
            end
        end
    end
    
    R2 = CalculateR2(ActSignalsTrunk,PredData.preddatabin)';
%     vaf= 1- (var(PredData.preddatabin - ActSignalsTrunk) ./ var(ActSignalsTrunk) );
    vaf = 1 - nansum( (PredData.preddatabin-ActSignalsTrunk).^2 ) ./ nansum( (ActSignalsTrunk - repmat(nanmean(ActSignalsTrunk),size(ActSignalsTrunk,1),1)).^2 );
    %vaf = 1 - nansum( (PredData.preddatabin(1:591)-ActSignalsTrunk(1:591)).^2 ) ./ nansum( (ActSignalsTrunk(1:591) - repmat(nanmean(ActSignalsTrunk(1:591)),size(ActSignalsTrunk(1:591),1),1)).^2 );
    %vaf = 1 - nansum( (PredData.preddatabin(592:1182)-ActSignalsTrunk(592:1182)).^2 ) ./ nansum( (ActSignalsTrunk(592:1182) - repmat(nanmean(ActSignalsTrunk(592:1182)),size(ActSignalsTrunk(592:1182),1),1)).^2 );
    mse= nanmean((PredData.preddatabin-ActSignalsTrunk) .^2);
    varargout = {R2, vaf, mse};

    assignin('base','R2',R2);
    assignin('base','vaf',vaf);
    assignin('base','mse',mse);
    aveR2 = mean(R2);
    avevaf= mean(vaf);
    avemse= mean(mse);
%     assignin('base','aveR2',aveR2);
%     assignin('base','avevaf',avevaf);
%     assignin('base','avemse',avemse);
        
    %Display R2
    if dispflag
        fprintf('\t\tR2  \tvaf  \tmse\n');
        for i=1:numPredSignals
           fprintf('%s\t%1.3f\t%1.3f\t%.2f\n',PredData.outnames{i},R2(i),vaf(i),mse(i));
        end
        fprintf('Averages:\t%1.3f\t%1.3f\t%.2f\n',aveR2,avevaf,avemse);
    end
    
    numberOfFolds = 10;
    results = struct;
        
    if plotflag  
        h = figure('name', 'Actual vs. Predicted');
        for i = 1:numPredSignals
            
            results(i).label = PredData.outnames{i};
            
            %Plot both Actual and Predicted signals
            subplot(numPredSignals,3,[3*i-2,3*i-1]);
            plot(ActualData.timeframe,ActSignalsFull(:,i),'k');
            hold on;
            plot(PredData.timeframe,PredData.preddatabin(:,i),'r');
            title(PredData.outnames{i});
            
            % adding in VAF values for each fold
            foldLengthTime = length(PredData.timeframe) / numberOfFolds;
            foldLengthData = length(PredData.preddatabin) / numberOfFolds; % this will be 5910/ 10 = 591. start: 591 * (j - 1)+1   end: 591 * (j)
            for j = 1:10
                lineLocation = PredData.timeframe(round(foldLengthTime * j));
                line([lineLocation lineLocation], [min(min(PredData.preddatabin(:,i)), min(ActSignalsFull(:,i)))*0.9 max(max(PredData.preddatabin(:,i)),max(ActSignalsFull(:,i)))*1.1], 'LineStyle', '--');
                foldStart = foldLengthData * (j-1) + 1;
                foldEnd = foldLengthData * j;
                foldSpecificVAF = 1 - nansum( (PredData.preddatabin(foldStart:foldEnd,i)-ActSignalsTrunk(foldStart:foldEnd,i)).^2 )./ nansum( (ActSignalsTrunk(foldStart:foldEnd,i) - repmat(nanmean(ActSignalsTrunk(foldStart:foldEnd,i)),size(ActSignalsTrunk(foldStart:foldEnd,i),1),1)).^2 );
                VAFMessage = ['VAF:' num2str(round(foldSpecificVAF*100)) '%'];
                text(lineLocation-0.9*foldLengthData*0.05, max(max(PredData.preddatabin(:,i)),max(ActSignalsFull(:,i)))*1.05, VAFMessage);  
                results(i).data(j) = foldSpecificVAF;
            end
            legend('Actual',['Predicted (Average VAF = ' num2str(round(vaf(i)*100)) '%)'], 'location', 'southeast');
            if i == numPredSignals
                xlabel(xLabel);
            end
            ylabel(yLabel);
            hold off;
            
            subplot(numPredSignals,3,3*i);
            plot(ActualData.timeframe(4848:5000),ActSignalsFull(4848:5000,i),'k');
            hold on;
            plot(PredData.timeframe(4848:5000),PredData.preddatabin(4848:5000,i),'r');            
%             plot(ActualData.timeframe(9848:10000),ActSignalsFull(9848:10000,i),'k');
%             hold on;
%             plot(PredData.timeframe(9848:10000),PredData.preddatabin(9848:10000,i),'r');
            %saveas(h, [pwd '/Figures/' PredData.outnames{i} '.fig']);    
        end
        
        %save(['Results/' PredData.outnames{length(PredData.outnames)}], 'results');
    end
end