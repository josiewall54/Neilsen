% have the user choose a mat file to analyze
% strip off the number extension to get the root name (I think this is
% David's convention)
% from the root name, create the names for all the variables in the file
% load in the variables
% extract the data around the time of the stimulations
% load them all into a traceemg data structure
% plot them on the screen
% done

predur = .5;  % the time before the stim to extract
postdur = 2;    % the time after the stim to extract

[fname, path] = uigetfile('*.mat');

[allresp,samptimes] = get_sacral_stim_data(fname,[predur postdur]);

nresp = size(allresp,2);
ts = mytimeseries;
for ii = 1:nresp    
 ts.Data = squeeze(allresp(:,ii,:))';
 ts.Time = samptimes';

 proc_fig = initialize_ts_gui(ts,[]) 
 set(gcf,'Name',['Stim trial ' num2str(ii)]);
 pause
end