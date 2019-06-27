ts = mytimeseries
ts.Time = 1:length(plexondata.emgdata.data(:,1));
ts.Data = abs(plexondata.emgdata.data(:,[2 5 6]));

ts2 = mytimeseries
ts2.Time = 1:length(plexondata.timeframe);
ts2.Data = [abs(plexondata.emgdatabin(:,[1 4 5])) plexondata.spikeratedata(:,[1:8])];
ts2.Data = [abs(plexondata.emgdatabin(:,[1 4 5])) plexondata.spikeratedata(:,[13])];

%%

ts2 = mytimeseries;
ts2.Time = 1:length(plexondata.emgdata.data(1:10000,1));
ts2.Data = [(plexondata.emgdatabin(1:10000,[5]))  an_data.binnedKinematicData.rawKinematics_ref_hip_middle(1:10000,end-2)];

%%
ts2 = mytimeseries;

temp = an_data.binnedEpiduralData.rawEpidural(:,1:end-500)';
tempkin = an_data.binnedKinematicData.rawKinematics_ref_hip_middle(1:end-500,:);
ts2.Time = 1:length(temp(:,13));
ts2.Data = [temp(:,13*5-1) tempkin(:,end-2)];

%%
ts2 = mytimeseries;

temppdat = an_data.data2';
temppdat = temppdat(1:5:end,:);
tempkdat = an_data.kinematicData.x(:,end) - an_data.kinematicData.x(:,2);
ind = 1:100000;
ts2.Time = 1:length(tempkdat(ind));
ts2.Data = [temppdat(ind,end-3) tempkdat(ind)];

%%
ts2 = mytimeseries;

tempEMG = an_data.binnedEpiduralData.rawEpidural(6*5,:)';
tempKin = an_data.binnedKinematicData.rawKinematics_ref_hip_middle(:,end-2);

ind = 1:(length(tempEMG)-500);
ts2.Time = ind;
ts2.Data = [tempEMG(ind) tempKin(ind)];

%%
ts2 = mytimeseries;

ts2.Time = 1:length(fielddata.rawEpiduralData.CAR3);
ts2.Data = [fielddata.data' emgdata.data(:,5)] ;
ts2.Data = [fielddata.rawEpiduralData.CAR3' emgdata.data(:,5)] ;
