function handles = scale_line(handles,index,gain)
%function handles = scale_line(handles,index,gain)
%
%   Function to scale the lines in a plot of the type created by
%   plot_matrix.  HANDLES is a structure with the information about the
%   figure and current plot.  It needs the handles to the axis (, to the
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

handles.oldygain = handles.ygain;  % copy the current gains into the old ones
handles.ygain(index) = gain;

old_data = get(handles.linehandles(index),'Ydata');   % the old data in the figure

old_data = (old_data-handles.yoffset(index))/handles.oldygain(index);  % undo the old transformation
old_data = handles.ygain(index)* old_data + handles.yoffset(index);  % do the new transformation

set(handles.linehandles(index),'Ydata',old_data);



