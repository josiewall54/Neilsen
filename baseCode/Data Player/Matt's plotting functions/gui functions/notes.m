function handles = select_current_trace(handles,action)
ax = handles.axishandle;

fig = gcbf;   % keep track of which figure the action took place in
currfig = get(ax,'Parent');
switch action
    case 'down'   % a button was pressed down
        def = handles.notes;
        if ~isempty(def)
            handles.notes = inputdlg({'response type','oscillatory?','notes'},'Classify response',2,def);
        else    
            handles.notes = inputdlg({'response type','oscillatory?','notes'},'Classify response',2);
        end        
end


        