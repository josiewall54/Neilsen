cd('/Users/josephinewallner/Desktop/LabWork/Nielsen/RatData/FES/N30')

stimFile = '19-01-24_stim.xlsx';
noStimFile = '19-01-24_nostim.xlsx';

stimData = importVicon(stimFile);
noStimData = importVicon(noStimFile);

%% Get correlations for all combinations
names = stimData.names;
for i = 1:7
    foreMarker = names{i};
    foreDataStimMaster = stimData.y(:,i);
    foreDataNoStimMaster = noStimData.y(:,i);
    lStim = length(foreDataStimMaster);
    lNoStim = length(foreDataNoStimMaster);
    for j = 1:3       
        hindMarker = names{j+7};
        hindDataStim = stimData.y(:,j+7);
        hindDataNoStim = noStimData.y(:,j+7);
        
        allNanStim = vertcat(find(isnan(foreDataStimMaster)), find(isnan(hindDataStim)));
        idxStim = setdiff(1:lStim, allNanStim);
        
        allNanNoStim = vertcat(find(isnan(foreDataNoStimMaster)), find(isnan(hindDataNoStim)));
        idxNoStim = setdiff(1:lNoStim, allNanNoStim);
        
        foreDataStim = foreDataStimMaster(idxStim);
        hindDataStim = hindDataStim(idxStim);
        
        foreDataNoStim = foreDataNoStimMaster(idxNoStim);
        hindDataNoStim = hindDataNoStim(idxNoStim);
        
        loc = 3 * i - 3 + j;
        
        tmp = corrcoef(foreDataNoStim, hindDataNoStim);
        corr(loc,1) = tmp(2);
        
        tmp = corrcoef(foreDataStim, hindDataStim);
        corr(loc,2) = tmp(2);
        
        %labels(loc) = [foreMarker ' / ' hindMarker]; 
    end
end

%% Look at coordination changes between stim & no-stim

% compute limb angles

hipTopStim = horzcat(stimData.x(:,1), stimData.y(:,1));
hipMidStim = horzcat(stimData.x(:,2), stimData.y(:,2));
footStim = horzcat(stimData.x(:,6), stimData.y(:,6));
shoulderStim = horzcat(stimData.x(:,8), stimData.y(:,8));
elbowStim = horzcat(stimData.x(:,9), stimData.y(:,9));
handStim = horzcat(stimData.x(:,10), stimData.y(:,10));

v1 = hipTopStim - hipMidStim;
v2 = footStim - hipMidStim;
limbFootStim = find_angle(v1,v2)';
idx = (limbFootStim < 0);
temp = idx.*(limbFootStim + 180) + ~idx.*limbFootStim;
limbFootStim = temp;

v3 = shoulderStim - elbowStim;
v4 = handStim - elbowStim;
limbHandStim = find_angle(v3,v4)';
idx = (limbHandStim < 0);
temp = idx.*(limbHandStim + 180) + ~idx.*limbHandStim;
limbHandStim = temp;
timeStim = 0:0.005:length(limbFootStim)*0.005 - 0.005;
        

hipTopNoStim = horzcat(noStimData.x(:,1), noStimData.y(:,1));
hipMidNoStim = horzcat(noStimData.x(:,2), noStimData.y(:,2));
footNoStim = horzcat(noStimData.x(:,6), noStimData.y(:,6));
shoulderNoStim = horzcat(noStimData.x(:,8), noStimData.y(:,8));
elbowNoStim = horzcat(noStimData.x(:,9), noStimData.y(:,9));
handNoStim = horzcat(noStimData.x(:,10), noStimData.y(:,10));

v1 = hipTopNoStim - hipMidNoStim;
v2 = footNoStim - hipMidNoStim;
limbFootNoStim = find_angle(v1,v2)';
idx = (limbFootNoStim < 0);
temp = idx.*(limbFootNoStim + 180) + ~idx.*limbFootNoStim;
limbFootNoStim = temp;

v3 = shoulderNoStim - elbowNoStim;
v4 = handNoStim - elbowNoStim;
limbHandNoStim = find_angle(v3,v4)';
idx = (limbHandNoStim < 0);
temp = idx.*(limbHandNoStim + 180) + ~idx.*limbHandNoStim;
limbHandNoStim = temp;
timeNoStim = 0:0.005:length(limbHandNoStim)*0.005 - 0.005;

%% Correlation between limbs - take 2

hipFootStimAll = hipTopStim(:,1) - footStim(:,1);
shoulderElbowStimAll = shoulderStim(:,1) - elbowStim(:,1);
%shoulderHandStimAll = shoulderStim(:,1) - handStim(:,1);

hipFootNoStimAll = hipTopNoStim(:,1) - footNoStim(:,1);
shoulderElbowNoStimAll = shoulderNoStim(:,1) - elbowNoStim(:,1);
%shoulderHandNoStimAll = shoulderNoStim(:,1) - handNoStim(:,1);

%hipFoot & shoulderElbow
idxStim = setdiff(1:length(hipFootStimAll), vertcat(find(isnan(hipFootStimAll)), find(isnan(shoulderElbowStimAll))));
hipFootStim = hipFootStimAll(idxStim);
shoulderElbowStim = shoulderElbowStimAll(idxStim);
[Rstim_elbow, lagsStim_elbow] = xcorr(hipFootStim, shoulderElbowStim, 'coeff');

idxNoStim = setdiff(1:length(hipFootNoStimAll), vertcat(find(isnan(hipFootNoStimAll)), find(isnan(shoulderElbowNoStimAll))));
hipFootNoStim = hipFootNoStimAll(idxNoStim);
shoulderElbowNoStim = shoulderElbowNoStimAll(idxNoStim);
[RnoStim_elbow, lagsNoStim_elbow] = xcorr(hipFootNoStim, shoulderElbowNoStim, 'coeff');

figure
subplot(2,1,1)
hold on
plot(hipFootStim, 'k')
plot(shoulderElbowStim, 'c')
ylabel('Stim')

subplot(2,1,2)
hold on
plot(hipFootNoStim, 'k')
plot(shoulderElbowNoStim, 'c')
ylabel('No Stim')

% %hipFoot & shoulderHand
% idxStim = setdiff(1:length(hipFootStimAll), vertcat(find(isnan(hipFootStimAll)), find(isnan(shoulderHandStimAll))));
% hipFootStim = hipFootStimAll(idxStim);
% shoulderHandStim = shoulderHandStimAll(idxStim);
% [Rstim_hand, lagsStim_hand] = xcorr(hipFootStim, shoulderHandStim, 'coeff');
% 
% idxNoStim = setdiff(1:length(hipFootNoStimAll), vertcat(find(isnan(hipFootNoStimAll)), find(isnan(shoulderHandNoStimAll))));
% hipFootNoStim = hipFootNoStimAll(idxNoStim);
% shoulderHandNoStim = shoulderHandNoStimAll(idxNoStim);
% [RnoStim_hand, lagsNoStim_hand] = xcorr(hipFootNoStim, shoulderHandNoStim, 'coeff');
