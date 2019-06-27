function handles = plot_matrix_callback(handles, action, varargin)
%  function handles = plot_matrix_callback(handles, action, varargin)
%

handles = guidata(gcf);

switch action
    case {'scale','zoomy','scaley'}
        index = varargin{1};
        val = get(gcbo,'Value');  % get the slider value
        mult = .8^sign(-val);  % what to multiply the current gain by
        set(gcbo,'Value',0);   % reset the slider value
        gain = round(100*handles.ygain(index)*mult)/100;
        handles = scale_line(handles,index,gain);

    case {'scrollx'}
        val = get(handles.scrollx_slider,'Value');  % this is a percentage value
        
        % the total range that could be shown for this file
 
        try %ugly ugly hack
            realxrange = size(handles.dat,1);    % the number of samples sts.nsamp2-sts.nsamp1;
        catch
            realxrange = size(handles.dat.Data,1);    % the number of samples sts.nsamp2-sts.nsamp1;
        end
        
        newmidpoint = round(val*realxrange/100);  % the new midpoint

        % find the current view
        width = handles.viewstop - handles.viewstart;
              
        % find the new start and stop points, preserving the current width
        handles.viewstart = (newmidpoint - round(width/2));  
        handles.viewstop = (newmidpoint + round(width/2));
        
        % replot the data
        handles = replot_data(handles);
                
        
    case {'playbutton','stopbutton','rewindbutton','fastforwardbutton'}
        handles = playbutton_controls(handles,action,varargin{:});

    case {'comments'}
        if isa(handles.dat,'mytimeseries')
            info = get(handles.dat,'dataInfo');
            disp('experiment notes:')
            disp(info.Notes_to_be_saved_in_file_header)
        end

%     case {'idtimes'}
%         handles = idtimes(handles,varargin{:});
%     case {'zoomx','xzoom'}
%         handles = zoomx(handles,varargin{:});        
%     case {'filter_display'}
%         handles = filter_display(handles,varargin{:});        
%     case {'notes'}
%         handles = notes(handles,varargin{:});        
%     case {'save_info'}
%         handles = save_info(handles,varargin{:});        
%     case {'select_current_trace'}
%         handles = select_current_trace(handles,varargin{:});
        
    case  {'mouse_toggle_button'}
        label = get(handles.mouse_toggle_button,'String');
        nfunc = length(handles.mouse_functions);
        ind = find(strcmp(label,handles.mouse_functions));
        if ind == nfunc   % if it's the last one, then go back to the first one
            ind = 1;
        else
            ind = ind +1;
        end
        label = handles.mouse_functions{ind};
        set(handles.mouse_toggle_button,'String',label);

        callbackString = ['plot_matrix_callback(guidata(gcf),''' label ''',''down'');'];
        set(gcf,'WindowButtonDownFcn',callbackString);

    case 'mouse_toggle_menu'
        func_str = varargin{1};
        callbackString = ['plot_matrix_callback(guidata(gcf),''' func_str ''',''down'');'];
        set(gcf,'WindowButtonDownFcn',callbackString);
        
    otherwise
        func = str2func(action);
        handles = func(handles,varargin{:});

%         disp('unknown action in plot_matrix_callback')
end

guidata(gcf,handles);


    