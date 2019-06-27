function handles = save_info(handles,action)

assignin('base','ided_times',handles.all_ided_times);
assignin('base','notes',handles.notes)

if action ~= -1
    msgbox('ided_times and notes saved to base workspace','save info')
end

fig = get(handles.axishandle,'Parent');
name = get(fig,'Name');
name = [name ' SAVED'];
set(fig,'Name',name);
