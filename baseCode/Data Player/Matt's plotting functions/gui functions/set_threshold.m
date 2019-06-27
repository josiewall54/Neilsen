function handles = set_threshold(handles,action)
% function to allow user to set the threshold on the currently selected
% trace.  If there is no currently selected trace, then it returns an
% error.  If there is a selected trace, then it lets the use place a
% threshold line, using the left button to move it around.  Then when the
% user double clicks, it opens a popup with the extracted events.
%

ax = handles.axishandle;

fig = gcbf;   % keep track of which figure the action took place in
currfig = get(ax,'Parent');  % keep the figure in which the current axis is located
switch action
    case 'down'
        selType = get(fig,'SelectionType');  % see if it's a double click
        currPt  = get(ax,'CurrentPoint');
        
        if strcmp(selType,'normal')    % This sets a threshold, as long as a channel is selected
            if handles.current_trace == max(handles.yoffset+.5)+1; % there isn't a trace currently selected
                disp('need to select a trace first')
                return
            end
            index = handles.current_trace;  % the currently selected trace index
            currPt  = get(gca,'CurrentPoint');  % get the point that they've selected in the window
            yval = currPt(1,2);  % this is the y value of the point they selected.
            xlim = get(ax,'XLim');
            if isfield(handles,'thresh_line')
                if ishandle(handles.thresh_line)
                    delete(handles.thresh_line);
                end
            end
            
            handles.threshold(index) = yval; % assign the threshold value
            handles.real_threshold(index) = (yval-handles.yoffset(index))/handles.ygain(index);  % undo the old transformation
%             disp(handles.real_threshold(index))  % show the actual value for the threshold here
            handles = replot_data(handles);
            
        elseif strcmp(selType,'alt')  % right click - extract out the events above the threshold and plot them in a separate window
            if handles.current_trace == max(handles.yoffset+.5)+1; % there isn't a trace currently selected
                disp('need to select a trace first')
                return
            end
            index = handles.current_trace;  % the currently selected trace index
            samples = get_view();
            handles.dat.nsamp1 = samples(1);
            handles.dat.nsamp2 = samples(2);
            handles.dat = updateData(handles.dat);
            
            data = handles.dat.Data;  % the data for the period
            %             times = ets.Time;  % the times for the period
            spt = sp_times(data(:,index),handles.real_threshold(index)); % find the spike events in the scaled data
            aps = sp_extract(data(:,index),spt,30,50);  % arbitrary windows to use
            figure
            plot(aps','b')
        end
end
