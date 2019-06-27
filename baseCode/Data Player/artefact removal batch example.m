
%% illustrate the basics of the new data structures
[info, newdat, newtimes] = readlabviewfile('rat042013.lbv','all');   % read in the data - note that the times are returned as well
myts = mytimeseries;   % this is the new type of data class (instead of traceemg)
myts = set(myts,'data',newdat');   %  set the data for the object
myts = set(myts,'time',newtimes);   % set the times
plot(myts);   % plot the data, with the artefact

%%  creates an interactive GUI for manipulating and examining the data
initialize_ts_gui(myts)

%%  get rid of the stim artefact
%  the following function gets rid of the artefact, based on a threshold
%  crossing - for the negative going phase of the artefact which is the
%  more robust one - returns the 'clean' data in newdat2, and the trace of
%  the stimulation train, as determined by the artefact

[newdat2,stimtimes] = remove_stim_artifact(newdat');
newdat2(:,6) = stimtimes;   % put the stimulation train in the last channel
myts = set(myts,'data',newdat2(:,1:6));   % only assign in the first 6 channels, since these are the ones we care about
plot(myts);    % plot the data

%%  make the GUI for the artefact free data
initialize_ts_gui(myts)
