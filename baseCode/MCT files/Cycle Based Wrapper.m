
%%  identify cycles based on the kinematics

[KINdat, KINtimes] = get_CHN_data(kinematicData,'raw');
[b,a] = butter(2,.25/(kinematicData.freq/2),'high');
temp = kinematicData.refKinMatrix(:,end-2);  % pull out the foot x coordinate
temp2 = inpaint_nans(temp);  % deal with the NaN, using Pablo's function
temp3 = filtfilt(b,a,temp2);   % filter the stepping to get rid of drifts
ndatsamp = length(temp3);

[ons,offs] = find_bursts(temp3,.2*max(temp3),1);  % find windowsthat contain the maxima of the trace
% now find the maxima within each of those windows,rejects any cycles that
% are too short or too long
onsets = get_cycle_onsets_from_ided_times(temp3,[ons; offs]',[50 200]); 
allphases = onsets2phase(onsets,size(temp,1));
allphases2 = allphases(1:10:end);

%% this tries to find blocks of good stepping that can then be combined together
minnsamples = 200;

gaps = onsets(1:(end-1),2) - onsets(2:end,1);  % the #of samples between the offset of the Nth and the onset of the N+1th cycle
ind = find(gaps < -1);  % the indices to the cycles that have a gap
% the number of samples in each continuous block of walking

ind(end+1) = size(onsets,1);  % include the last bout as well
nsamp2 = onsets(ind(2:end),2) - onsets(ind(1:end-1)+1,1)+1;
% nsamp2(end+1) = ndatsamp - onsets(ind(end),2);
ind2  = find(nsamp2 > minnsamples);
coffsets = onsets(ind(ind2+1),2);
consets = onsets(ind(ind2)+1,1);

onsets2 = [consets coffsets];

binsize = 0.05;
[b,a] = butter(2,2*(binsize/2),'high');

inputstruct = fielddata;
outputstruct = kinematicData;
inputdata = []; outputdata = []; outputtimes = []; outphases = [];
for jj = 1:size(onsets2)  %  iterate over the different cycles
    ind = onsets2(jj,1):onsets2(jj,2);   % these are the indices for this step
    origtimes = KINtimes(ind);   % the times for this step,as defined from the original data

    [incycle,cyc_times] = get_CHN_data(inputstruct,'binned',origtimes);  % get the binned data from the data you care about
    [outcycle,cyc_times] = get_CHN_data(outputstruct,'binned',origtimes);  % get the binned data from the data you care about

    temp = find_joint_angles(outcycle,kinematicData.KinMatrixLabels);
    outcycle = temp.limb;

    nsamp = min(size(incycle,1),size(outcycle,1));
    ind2 = ind(1:10:end);
    outphases = [outphases; allphases(ind2(1:nsamp))];
    
    incycle = filtfilt(b,a,incycle);  

    outcycle = filtfilt(b,a,outcycle);  
    inputdata = [inputdata; incycle(1:nsamp,:)];
    outputdata = [outputdata; outcycle(1:nsamp,:)];

    inputdata(end+1,:) = NaN;
    outputdata(end+1,:) = NaN;
    outphases(end+1) = NaN;

    outputtimes = [outputtimes cyc_times(1:nsamp)];
    outputtimes(end+1) = outputtimes(end)+.05;
end
outputtimes = (0:.05:(length(outputdata)-1)*.05)';
ind = find(outputtimes > 50);
outputtimes = outputtimes(ind);
outputdata = outputdata(ind,:);
inputdata = inputdata(ind,:);
outphases = outphases(ind);

%%  visual inspection

ts = mytimeseries;
ts.Time = 1:length(temp3);
ts.Data = temp3;
initialize_ts_gui(ts);
set_ided_times({onsets2, onsets});  % put the onsets into the window and let the user evaluate

% execute this line if you've updated the onsets and saved them in the workspace
%onsets = ided_times{1};

%%  now extract data according to each of those steps and normalize them

nbin = 10;  % the number of samples in the normalized step
data = fielddata;  % this is the data we want to look at

[KINdat, kintimes] = get_CHN_data(kinematicData,'raw');  % get the kinematic times - since that is what was used to define the onsets
% onsets3(:,1) = onsets(:,1);  % these are redundant, but I had included them so as to deal with interpolation at edges
% onsets3(:,2) = onsets(:,2);
alln2cycle = zeros(2,2,2);
for jj = 1:size(onsets,1)  %  iterate over the different cycles
    ind = onsets(jj,1):onsets(jj,2);   % these are the indices for this step
    origtimes = kintimes(ind);   % the times for this step,as defined from the original data
    [cycle,cyc_times] = get_CHN_data(data,'binned',origtimes);  % get the binned data from the data you care about
    allcycles{jj} = cycle;  %  this is a matrix of  values for this step
    allcyc_times{jj} = cyc_times;  %  the times corresponding to the samples in the extracted cycles
    nchan = size(cycle,2);  % the number of channels 
    for ii = 1:nchan  % iterate over the different channels
        ncycle = normalize_cyclesNaN_v2((cycle(:,ii)),cyc_times,nbin)';  %  normalize the step
        alln2cycle(ii,jj,1:nbin) = ncycle;
    end
end

%%
tuning = squeeze(nanmean(alln2cycle,2));
temp3 = tuning;
temp2 = tuning - repmat(min(tuning')',1,nbin);
temp3 = temp2./repmat(max(temp2')',1,nbin);
imagesc(temp2(5:5:end,:));

%%
temp = temp2(1:end,:);
[mx,mxind] = max(temp');
[junk,ind2] = sort(mxind);
imagesc(temp3(ind2,:));



%%

APdat = get_CHN_data(spikedata,'binned',kintimes);
FIELDdat = get_CHN_data(fielddata,'binned',kintimes);
KINdat = get_CHN_data(kinematicData,'raw',kintimes);
data = temp3;
nchan = size(data,2);
for ii = 1:nchan
    cycles = extract_cycledata(data(:,ii),round(onsets2));
    ncycles = normalize_cyclesNaN_v2((cycles'),original_times,10)';
    allcycles{ii} = cycles;
    allncycles{ii} = ncycles;
end

ind2 = -2:12;

%%  now extract the data according to these cycle definitions

[kindat,kintimes] = get_CHN_data(kinematicData,'raw');
% [APdat,APtimes] = get_CHN_data(spikedata,'raw', kintimes);
EMGdat = get_CHN_data(emgdata,'raw',kintimes);
data = EMGdat;
nchan = size(data,2);
for ii = 1:nchan
    onsets2(:,1) = onsets(:,1)-10;
    onsets2(:,2) = onsets(:,2)+10;
    cycles = extract_cycledata(data(:,ii),onsets2*5);
    ncycles = normalize_cyclesNaN(abs(cycles'),50)';
    allcycles{ii} = cycles;
    allncycles{ii} = ncycles;
end




