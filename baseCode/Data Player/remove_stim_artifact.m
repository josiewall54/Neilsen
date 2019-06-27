function [newdat, stimtimes] = remove_stim_artifact(dat,varargin)
%function [newdat, stimtimes] = remove_stim_artifact(dat,value,window)
%    Function to remove stimulation artifact from a data set.  Uses the
%    negative going artifact as this is more robust, finds when this
%    crosses 4SD of the summed activity, then blanks the artifact.  VALUE
%    is an optional argument specifying what value to replace the artifact
%    with (defaults to 0).  WINDOW is also optional and specifies the pre
%    and post times to blank out (defaults to [10 20] - i.e. 10 before and 20 after).
%

value = 0;
window = [10 30];
if nargin > 1
    value = varargin{1};
end
if nargin > 2
    window = varargin{2};
end

[nr,nc] = size(dat);
if nc > nr
    dat = dat';
end

temp = sum(dat');
sd = std(temp);
ind = find(temp < -4*sd);
ind2 = find(diff(ind) > 1);

onsets = [ind(ind2) ind(end)];

wind = (-window(1)):window(2);
allinds = repmat(wind,length(onsets),1);
allinds2 = allinds + repmat(onsets',1,size(allinds,2));

newdat = dat;
newdat(allinds2,:) = value;

stimtimes = newdat(:,1)*0;
stimtimes(onsets) = 1;
