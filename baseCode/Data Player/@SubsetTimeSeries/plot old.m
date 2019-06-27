function plot(sts)
%SubsetTimeSeries

% Define variables
stsPlot = sts;
nsamp2 = stsPlot.nsamp2; %last sample in current view
nsamp1 = stsPlot.nsamp1; %first sample in current view
downSample = sts.downSample; %number of samples to skip between samples read in from file
totalNumberSamplesInCurrentView = (nsamp2 - nsamp1)/downSample; %total number of samples in current view

% Get current figure/axes
ax = gca; %Current axes
set(ax,'Units','pixels'); %Set the axis units to 'pixels' 
axesPosition = get(ax,'Position'); %Returns [left bottom width height]
xAxisWidthInPixels = axesPosition(3); %Length of x-axis in pixels
doubleXAxisPixels = xAxisWidthInPixels*2; %Doubling the number of pixels on the x-axis

if totalNumberSamplesInCurrentView > doubleXAxisPixels %number of samples is greater than what can be displayed
    % Get new downsample based on pixels and total number of samples in the
    % current view, use updateData to pull data from file, and plot data
    display('Too many samples to display. Getting new downsample and plotting.');
    downSample = floor(totalNumberSamplesInCurrentView/doubleXAxisPixels)*downSample; %newDownSample figured from total number of samples that can be viewed
    stsPlot = updateData(stsPlot,nsamp1,nsamp2,downSample); %read data from file
else
    display('Plotting all samples.');
    stsPlot = updateData(stsPlot,nsamp1,nsamp2,downSample);%read data from file
end


plot@timeseries(stsPlot);%call to timeseries plot function