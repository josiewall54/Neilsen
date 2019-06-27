function [linehandles, startview, stopview] = plot(sts, varargin)
% function [linehandles, startview, stopview] = plot(sts, time1,time2,nsamp1,nsamp2)
% function to plot an sts object according to the view defined in nsamp1
% and nsamp2 - checks the requested view against it's own properties and
% against the screen where it's being plotted and the displays things
% somewhat intelligently
%

if (nargin > 1) & (nargin < 4)  % if they sent in times, they're in terms of times and indicate the view to show
    nsamp1 = varargin{1}/sts.period;
    nsamp2 = varargin{2}/sts.period;
elseif (nargin > 3)       % they've sent in sample numbers
    nsamp1 = varargin{3};   
    nsamp2 = varargin{4};
else
    nsamp1 = sts.nsamp1;  % otherwise look at the times in the object itself
    nsamp2 = sts.nsamp2;
end
    
stsPlot = sts;

newmidpoint = mean([nsamp1 nsamp2]);
newwidth = nsamp2 - nsamp1;

% % make sure the width isn't too large
% % newwidth = min([handles.maxrangetoshow newwidth]);  
% newwidth = min([newwidth  round((sts.time2-sts.time1)/sts.period)]);

% oldmidpoint = handles.oldmidpoint;
% oldwidth = handles.oldwidth;

% make sure left point is no less than 0, and no less than the mininum value as specified by the 'master' sts object 
new_nsamp1 = max([nsamp1 0 sts.nsamp1]); 
% make sure the right point is no greater than the total number of samples,and no less than the max value in the master sts 
new_nsamp2 = min([nsamp2 sts.totNumSamples sts.nsamp2]);

% now take care of things if the values have been altered, to make sure the
% requested width is perserved
% if (new_nsamp1 ~= nsamp1)  % the left point had to be modified
%     new_nsamp2 = new_nsamp1 + newwidth;
% elseif new_nsamp2 ~= nsamp2   % the right point had to be changed (and not the left point)
%     new_nsamp1 = new_nsamp2 - newwidth;
% end

% prepare and update the sts Plotting object
stsPlot.nsamp1 = round(new_nsamp1);   % these are in terms of times again
stsPlot.nsamp2 = round(new_nsamp2);
stsPlot.downSample = sts.downSample;
stsPlot = UpdateSTSForPlot(stsPlot,gca);

% plot the data as specified in the sts object
dat = stsPlot.Data;

times = stsPlot.Time;

linehandles = plot_matrix(dat,times);
startview = new_nsamp1;
stopview = new_nsamp2;


