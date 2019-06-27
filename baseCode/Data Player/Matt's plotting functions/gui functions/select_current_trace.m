function handles = select_current_trace(handles,action)
ax = handles.axishandle;

fig = gcbf;   % keep track of which figure the action took place in
currfig = get(ax,'Parent');
switch action
    case 'down'   % a button was pressed down
        old_trace = handles.current_trace;  % the previously current trace
        selType = get(gcbf,'SelectionType');
        currPt  = get(gca,'CurrentPoint');
        yval = currPt(1,2); 
        boundaries = [handles.yoffset+.5 0];
        ind = find(yval < boundaries);
        if isempty(ind) % make sure there actually is one that meets the criterion
            ind = 1;
        end
        if ind(end) == length(boundaries)
            ind = length(boundaries)-1;
        end
        handles.current_trace = ind(end);  % the identity of the channel which is currently selected
        temp = findobj(handles.axishandle,'type','line');
        set(temp,'Color',[0 0 0])
        if handles.current_trace ~= old_trace      
            ind2 = find(temp == findobj(temp,'tag',num2str(ind(end))));
            set(temp,'Color',[.7 .7 .7])
            set(temp(ind2),'Color',[0 0 0])
        else
            handles.current_trace = max(handles.yoffset+.5)+1;
        end

%         ided_times = get_ided_times(handles.axishandle);
%         handles.all_ided_times{old_trace} = ided_times;  % read off and save the ided_times from the previous occasion
        curr_ided_times = handles.all_ided_times{handles.current_trace}; % pick out the ided_times for the selected channel
        show_ided_times(curr_ided_times,handles.axishandle);  % this will display the current trace's ided times
        
    case 'motion'  % the mouse is moving across the screen

    case 'up'   % they've released the mouse button
    
end

