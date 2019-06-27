function handles = replot_data(handles)


%  find the ided_times if there are any patches on the axis - do this
%  before plotting the updated data
handles.all_ided_times{handles.current_trace} = get_ided_times(handles.axishandle);

axes(handles.axishandle)  % set the EMG axis to be the current one

handles.viewstop = min([handles.viewstop (handles.viewstart+handles.maxrangetoshow)]);  % check that they're not requesting too much data

% this is the general part - each data object should know how to plot
% itself

flag = 0;
if isfield(handles,'linehandles')
    for i = 1:length(handles.linehandles)
        col{i} = get(handles.linehandles(i),'Color');
    end
    flag = 1;
end

[handles.linehandles, handles.viewstart, handles.viewstop] = plot(handles.dat,[],[],handles.viewstart, handles.viewstop,'samples');  % class specific plotting function

nchan = length(handles.linehandles);
if flag
    for i = 1:length(handles.linehandles)
        set(handles.linehandles(i),'Color',col{i});
    end
end

nlines = length(handles.linehandles);
set(handles.axishandle,'YTick',[]);

gains = handles.ygain;  % the previous gains before the current replotting

handles.ygain = ones(1,nlines);     % reset the gains for each channel according to how plot_matrix does this (a bit of a hack here)
handles.oldygain = handles.ygain;  %

handles = scale_line(handles,[],gains);  % recale the channels with the old gain
% drawnow

%delete(handles.midpointline);

if handles.current_trace ~= (nchan+1)  % there's a selected trace, so show the threshold
    yval = handles.real_threshold(handles.current_trace); % the threshold for the current trace, if it exists
    xlim = get(handles.axishandle,'Xlim');
    if isfield(handles,'thresh_line')
        if ishandle(handles.thresh_line)
            delete(handles.thresh_line)
        end
    end
    yval = handles.ygain(handles.current_trace)* yval + handles.yoffset(handles.current_trace);  % do the new transformation    
    handles.thresh_line = line(xlim,[yval yval]); % draw the line
end

% update the values in the handles structure
handles.newmidpoint = mean([handles.viewstart handles.viewstop]);
handles.newwidth = handles.viewstart - handles.viewstop;

show_ided_times(handles.all_ided_times{handles.current_trace},handles.axishandle);

% the below updates the labels for the scale texts
set(handles.axishandle,'Units','normalized')
xlim = double(get(handles.axishandle,'Xlim'));
for index = 1:nlines
    if isfield(handles,'scaletext') & ishandle(handles.scaletext(index))
        delete(handles.scaletext(index));
    end
    handles.scaletext(index) = text(xlim(2)+.04*(xlim(2)-xlim(1)),handles.yoffset(index),num2str(.5./handles.ygain(index)));
end

% the below updates the labels for each channel
for index = 1:nlines
    if isfield(handles,'labelstext_handles') & ishandle(handles.labelstext_handles(index))
        delete(handles.labelstext_handles(index));
    end
    handles.labelstext_handles(index) = text(xlim(1)-.1*(xlim(2)-xlim(1)),handles.yoffset(index),handles.labels{index});
    set(handles.labelstext_handles(index),'Rotation',-90)
end

% now update the scrollx slider if it exists
if isfield(handles,'scrollx_slider') & ishandle(handles.scrollx_slider)
% update the scrollbar
    try   % ugly ugly hack
        [nr,nc] = size(handles.dat);  %% should be overloaded - gives the total size of the subset
    catch
        [nr,nc] = size(handles.dat.Data);  %% should be overloaded - gives the total size of the subset
    end
    
    realxrange = nr;    %handles.sts.nsamp2 - handles.sts.nsamp1;   % the total range that can be shown from this file
    viewxrange = handles.viewstop - handles.viewstart;   % the size of the current window
    
    realmid = (handles.viewstart + handles.viewstop)/2;  % the current midpoint
    viewmid = realmid - 1; %  handles.sts.nsamp1; I can't figure out a good way to deal with this % how far in the real range the current plot is - the mid point plus the mininum value in the sts
    offset = 100*(viewxrange/2)/realxrange;  % this is the fraction of the max possible window that the current one is
    currmid = 100*viewmid/realxrange;  % how far the current mid point is in percentage    

    nviews = realxrange/viewxrange;   % the number of currently sized windows that can be shown
    step = 1/(1.5*nviews);  %  this is how much the large step button press changes the window position

    if isfield(handles,'scrollx_slider')
        set(handles.scrollx_slider,'Sliderstep',[step/10 step]);
        set(handles.scrollx_slider,'Max',100-offset);
        set(handles.scrollx_slider,'Min',offset);
        val = max(offset,currmid);
        val = min(100-offset,val);
        set(handles.scrollx_slider,'Value',val);   % never set the current value below the mininum value
    end

end

% take care of the videodata if there is any to show
if ~isempty(handles.videoData)   % update the videoData if there is any
    axes(handles.videoaxishandle)  % set the video axis to be the current one
    xlim = get(handles.videoaxishandle,'XLim');
    ylim = get(handles.videoaxishandle,'YLim');
    fig = gcf;
%     h = msgbox('loading video..., please wait');
    videoFrameNb = handles.videoData.getFrameFromSample(handles.dat, handles.newmidpoint);  % here the data object has to be a EMGsts
    videoFrame = handles.videoData.selectFrame(videoFrameNb);
    figure(fig)
    image(videoFrame);
    title(videoFrameNb);
    set(handles.videoaxishandle,'XLim',xlim);   % keep the current view
    set(handles.videoaxishandle,'YLim',ylim);
    set(handles.videoaxishandle,'XTick',[])
    set(handles.videoaxishandle,'YTick',[])
    set(gcf,'Menu','none')
    set(gcf,'ToolBar','figure')
%     delete(h)
    
    ylim = get(handles.axishandle, 'Ylim');
    xlim = get(handles.axishandle, 'Xlim');
    meanxlim = mean(xlim);
    axes(handles.axishandle)  % set the EMG axis to be the current one
    hold on;
    handles.midpointline = plot([meanxlim meanxlim], ylim, 'r');
    hold off;

end

