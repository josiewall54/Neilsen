function stsPlot = UpdateSTSForPlot(sts,varargin)
%   function stsPlot = UpdateSTSForPlot(sts,varargin)
%       Function to plot a subset time series object.  The data is
%       contained in STS.  It looks at the current view for the STS object,
%       then looks at the number of pixels in the axis defined by optional 
%       argument AX (if not specified, it uses the current axis).  
%       If the current view has has more samples than can be displayed,
%       then it downsamples the data.
%       It then updates the STS data with the new view appropriate for
%       plotting in STSPLOT.  It does no plotting itself.
%

if nargin == 1
    ax = gca;
else
    ax = varargin{1};
end

% Define variables
stsPlot = sts;
nsamp2 = stsPlot.nsamp2; %last sample in current view
nsamp1 = stsPlot.nsamp1; %first sample in current view
downSample = sts.downSample; %number of samples to skip between samples read in from file
totalNumberSamplesInCurrentView = (nsamp2 - nsamp1)/downSample; %total number of samples in current view

% Get current figure/axes
set(ax,'Units','pixels'); %Set the axis units to 'pixels' 
axesPosition = get(ax,'Position'); %Returns [left bottom width height]
xAxisWidthInPixels = axesPosition(3); %Length of x-axis in pixels
doubleXAxisPixels = xAxisWidthInPixels*2; %Doubling the number of pixels on the x-axis
set(ax,'Units','normalized'); 
if totalNumberSamplesInCurrentView > doubleXAxisPixels %number of samples is greater than what can be displayed
    % Get new downsample based on pixels and total number of samples in the
    % current view, use updateData to pull data from file, and plot data
%     display('Too many samples to display. Getting new downsample and plotting.');
    downSample = floor(totalNumberSamplesInCurrentView/doubleXAxisPixels)*downSample; %newDownSample figured from total number of samples that can be viewed
    stsPlot = updateData(stsPlot,nsamp1,nsamp2,downSample); %read data from file
else
%     display('Plotting all samples.');
    stsPlot = updateData(stsPlot,nsamp1,nsamp2,downSample);%read data from file
end

% dat = sts.Data;
% times = sts.Time;
% line_handles = plot_matrix(dat,times,ax);  % this plots the raw data in the screen


