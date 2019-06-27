function handles = scale_line(handles,index,gain)
%function handles = scale_line(handles,index,gain)
%
%   Function to scale the lines in a plot of the type created by
%   plot_matrix.  HANDLES is a structure with the information about the
%   axes and current plot.  It needs the handles to the axis (, to the
%   lines, and to the gain and offset values:
%            handles.axishandle;
%            handles.linehandles;
%            handles.yoffset;
%            handles.ygain;
%            handles.oldygain;
%            handles.oldyoffset;
%
%     INDEX specifies which line is the relevant one.
%     METHOD can either be 'max', which means it should scale the channel
%     to its maximum value in the display, or 'value', which means it
%     should scale the channel according to the value given in
%     handles.ygain
%

if isempty(index)
    index = length(gain);
end

if length(gain) > 1  % if they send all the gains, then do this recursively
    for ii = 1:length(gain)
        handles = scale_line(handles,ii,gain(ii));
    end
    return
end

handles.oldygain = handles.ygain;  % copy the current gains into the old ones
handles.ygain(index) = gain;

old_data = get(handles.linehandles(index),'Ydata');   % the old data in the figure

old_data = (old_data-handles.yoffset(index))/handles.oldygain(index);  % undo the old transformation
old_data = handles.ygain(index)* old_data + handles.yoffset(index);  % do the new transformation

set(handles.linehandles(index),'Ydata',old_data);

if handles.current_trace == index  % it's the selected trace
    yval = handles.real_threshold(handles.current_trace); % the threshold for the current trace, if it exists
    xlim = get(handles.axishandle,'Xlim');
    if isfield(handles,'thresh_line')
        if ishandle(handles.thresh_line)
            delete(handles.thresh_line)
        end
    end
    yval = handles.ygain(index)* yval + handles.yoffset(index);  % do the new transformation
    handles.thresh_line = line(xlim,[yval yval]); % draw the line
end

xlim = get(handles.axishandle,'Xlim');
if isfield(handles,'scaletext') & ishandle(handles.scaletext(index))
    delete(handles.scaletext(index));
end
handles.scaletext(index) = text(double(xlim(2)+.04*(xlim(2)-xlim(1))),handles.yoffset(index),num2str(.5./handles.ygain(index)));



