function [allresp,samptimes] = get_sacral_stim_data(fname,varargin)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

if nargin == 2
    predur = varargin{1}(1);
    postdur = varargin{1}(2);
else 
    predur = .5;  % the time before the stim to extract
    postdur = 2;    % the time after the stim to extract
end

rootname = strtok(fname,'_');

timesvar = [rootname '_Ch2*'];  % the variable with the stimulation
notevar = [rootname '_Ch30'];   % the variable with the comments

datavarnames = {[rootname '_Ch10'],[rootname '_Ch11'],[rootname '_Ch12'],[rootname '_Ch13']};  % the variables with the channel data

ndatavar = length(datavarnames);

temp = load(fname,timesvar);  % try to read in the stim times variable
if isempty(fieldnames(temp))  % if it's empty, make a dummy
    times_data = [];
    nstim = 0;
    times = [];
else    % otherwise, read off the values you care about
    fields = fieldnames(temp);
    times_data = temp.(fields{1});
    times = times_data.times;
    dtimes = diff(times);
    ind = find(dtimes > 1);
    times = times(ind);  % get rid of any pulses within trains
    nstim = length(times);
end
temp = load(fname,notevar);  % do the same thing for the notes
if isempty(fieldnames(temp))
    notes_data = [];
else
    notes_data = temp.(notevar);
end

for ii = 1:ndatavar   % go over each of the variables
    disp(['reading ' fname ' ' datavarnames{ii}]);
    temp = load(fname,datavarnames{ii});  % load in the data variable
    data = temp.(datavarnames{ii});
    for jj = 1:nstim  % go over each of the stimulation pulses
        sampn = round(1/data.interval*(times(jj)));  % this is the sample number for the pulse
        n1 = round(sampn - predur*1/data.interval);  % the starting sample
        n1 = max(1,n1);   % make sure it's not before the start of the trial
        n2 = round(sampn + postdur*1/data.interval);  % the stopping sample
        n2 = min(n2,data.length);  % make sure it's not after the end of the trial
        allresp(ii,jj,1:(n2-n1+1)) = data.values(n1:n2);  % collect the data
    end
    samptimes = ((n1:n2) - n1)*data.interval;
end
if nstim == 0
    allresp = [];
end

end

