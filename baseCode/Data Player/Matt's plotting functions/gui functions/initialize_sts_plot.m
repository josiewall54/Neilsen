function initialize_ts_gui(sts,varargin)
%  function intiialize_ts_gui(sts,chan2disp,videodata)
%    Function to initialize the parameters in a plot of the data in a STS
%    object.   VIDEODATA is optional and gives the videoData object with the
%    associated video data.  Put in an empty vector if there is no
%    associated video. CHAN2DISP is optional and gives the channesl to actually
%    show in the window.
%

handles.chan2disp = [];   % default values for these variables 
videoData = [];
if nargin > 1  % they sent in a channel list
    handles.chan2disp = varargin{1};
end

if nargin > 2  % they sent in a videoData object
    videoData = varargin{2};
end

% the handles will be stored in the guidata for the axis
figure  % make a new figure for the EMG data

handles.dat = sts;       % this is the sts with the complete set of data to be considered
handles.videoData = videoData;
handles.axishandle = gca;

handles.maxrangetoshow = 100000;   % this is the limit on the range of sample numbers to try to show at any given time - saves on the calls
totnsamp = size(handles.dat,1);

nsamp1 = 1;   % the first sample to show
nsamp2 = min([totnsamp nsamp1+handles.maxrangetoshow]);  % this is to determine the range of the current view

% find the subset of the subset, appropriate for being plotted
% stsPlot = sts;
% stsPlot.nsamp1 = nsamp1;
% stsPlot.nsamp2 = nsamp2;
% stsPlot = UpdateSTSForPlot(stsPlot,handles.axishandle);  % this finds the subset appropriate for the plotting
handles.viewstart = nsamp1;
handles.viewstop = nsamp2;

axes(handles.axishandle)  % set the EMG axis to be the current one
templinehandles = plot(handles.dat,[],[],nsamp1,nsamp2);
nchan = length(templinehandles);

% if isempty(handles.chan2disp) % they didn't send in  channel list, so use them all
%     handles.chan2disp = 1:nchan;
% else
%     nchan = length(handles.chan2disp);  % the actual number of channels on the plot
%     dat = dat(:,handles.chan2disp);  % get rid of the unused channels
% end
% 
handles.yoffset = (nchan:-1:1) - .5; % offsets for each channel - this is somewhat of a hack, based on my knowledge of what plot_matrix does
handles.oldyoffset = handles.yoffset;  % offsets for each channel
handles.ygain = ones(1,nchan);     % gains for each channel
handles.oldygain = handles.ygain;  % 
handles.scaletext(1:nchan) = -999;
[handles.labels{1:nchan}] = deal('');
handles.labelstext_handles(1:nchan) = -999;
handles.mouse_functions = {};
handles.running = 0;
handles.ided_times = cell(nchan,1);


if ~isempty(videoData)  % there actually is some videoData to display
    figure
    handles.videoaxishandle = gca;   % this is the axis to plot the video in
    videoFrame = handles.videoData.selectFrame(1);
    image(videoFrame);
    title(1);

    handles.newmidpoint = (nsamp1+nsamp2)/2;  % plot the red line in the middle of the plot to indicate the sample corresponding to the frame displayed
    ylim = get(handles.axishandle, 'Ylim');
    axes(handles.axishandle)  % set the EMG axis to be the current one
    handles.midpointline = plot([handles.newmidpoint handles.newmidpoint], ylim, 'r');
end

handles = replot_data(handles);    % this actually creates the plots

for ii = 1:nchan
    temp = get(handles.linehandles(ii),'Ydata');
    mx(ii) = max(temp - mean(temp));
    gain(ii) = 1/(2*mx(ii));
    gain(ii) = round(100*gain(ii))/100;
end

% scale the channels
handles = scale_line(handles,[],gain);  % scale the plots, the default should be to scale to maximum for each plot

% now set up the controls
% first add the ygain sliders to the left

handles = add_control(handles,'scale','slider');
handles = add_control(handles,'scrollx','slider');
handles = add_control(handles,'zoomx','mouse');
handles = add_control(handles,'playbuttons');
handles = add_control(handles,'idtimes','mouse');
handles = add_control(handles,'select_current_trace','mouse');
handles = add_control(handles,'mouse_toggle','pushbutton');

guidata(gcf,handles);  % put the data in the guidata
