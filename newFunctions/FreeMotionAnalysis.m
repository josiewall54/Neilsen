%% Free motion analysis
%Start with:
%   stretch of treadmill data - even multiple of 5*0.05
%   stretch of freemotion data (same length as treadmill data)

%Sequential combination:
%   1. create overall timeframe
%   2. concatenate treadmill then freemotion data - TreadmillThenFreemotion
%   3. concatenate freemotion then treadmill data - FreemotionThenTreadmill
%   4. Run decoder, look at prediction performance for freemotion folds

%Alternating combination:
%   1. Split treadmill data into 5 chunks (T1-T5)
%   2. Split freemotion data inot 5 chunks (F1-F5)
%   3. create overall timeframe
%   4. T1,F1,T2,F2,...,T5,F5 - TFAlternating
%   5. F1,T1,F2,T2,...,F5,T5 - FTAlternating


%% Sequential Combination
if size(treadmillTime,1) > size(freemotionTime,1)
    commonTime = freemotionTime;
else
    commonTime = treadmillTime;
end

commonFold = commonTime(end) / 5 - mod(commonTime(end) / 5, 0.05); %make each fold a multiple of 5ms
timeLength = commonFold * 10 - mod(commonFold * 10,2);
time = 0:0.05:timeLength;

if mod(length(time), 2) == 1 %need the time to be divisible by 2 and 0.05, fix this above
    halfTime = 0:0.05:(timeLength-0.05)/2;
    time = time(1:end-1);
else
    halfTime = 0:0.05:(timeLength)/2;
end

indices = find(halfTime >= 0);

treadmillEMGChunk = treadmillEMG.data(indices,:);
treadmillSpikeChunk = treadmillSpike(indices,:);
treadmillFieldChunk = treadmillField.data(indices,:);

treadmillKinChunk.ankle = treadmillKin.kinmeasures.ankle(indices);
treadmillKinChunk.limbfoot = treadmillKin.kinmeasures.limbfoot(indices);
treadmillKinChunk.hip = treadmillKin.kinmeasures.hip(indices);
treadmillKinChunk.knee = treadmillKin.kinmeasures.knee(indices);
treadmillKinChunk.toe = treadmillKin.kinmeasures.toeheight(indices);



freemotionEMGChunk = freemotionEMG.data(indices,:);
freemotionSpikeChunk = freemotionSpike(indices,:);
freemotionFieldChunk = freemotionField.data(indices,:);

freemotionKinChunk.ankle = freemotionKin.kinmeasures.ankle(indices);
freemotionKinChunk.limbfoot = freemotionKin.kinmeasures.limbfoot(indices);
freemotionKinChunk.hip = freemotionKin.kinmeasures.hip(indices);
freemotionKinChunk.knee = freemotionKin.kinmeasures.knee(indices);
freemotionKinChunk.toe = freemotionKin.kinmeasures.toeheight(indices);



combinedEMG = vertcat(treadmillEMGChunk,freemotionEMGChunk);
combinedSpike = vertcat(treadmillSpikeChunk,freemotionSpikeChunk);
combinedField = vertcat(treadmillFieldChunk,freemotionFieldChunk);

combinedKin.ankle = vertcat(treadmillKinChunk.ankle,freemotionKinChunk.ankle);
combinedKin.limbfoot = vertcat(treadmillKinChunk.limbfoot,freemotionKinChunk.limbfoot);
combinedKin.hip = vertcat(treadmillKinChunk.hip,freemotionKinChunk.hip);
combinedKin.knee = vertcat(treadmillKinChunk.knee,freemotionKinChunk.knee);
combinedKin.toeheight = vertcat(treadmillKinChunk.toe,freemotionKinChunk.toe);







