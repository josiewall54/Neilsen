function handles = save_info(handles,action)

assignin('base','ided_times',handles.all_ided_times);
assignin('base','notes',handles.notes)

msgbox('ided_times and notes saved to base workspace','save info')

