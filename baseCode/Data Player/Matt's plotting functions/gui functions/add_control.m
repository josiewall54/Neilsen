function handles = add_control(handles,control_function,uitype)
% function handles = add_control(handles,control_function,uitype)
%    Function to create mappings between control objects and functions.
%    Not that flexible at this point really - assumes a fixed set of
%    possibilities and just switches.
%

ax = handles.axishandle;
set(ax,'Units','normalized');
axpos = get(ax,'Pos');  %l b w h
fig = get(ax,'Parent');

switch control_function
    case {'yzoom','scale'}
        switch uitype
            case 'slider'
                % make the sliders for y zooming/scaling  - they're on the left hand side
                lineh = handles.linehandles;
                nline = length(lineh);
                axheight = axpos(4);
                winsize = axheight/nline;
                sliderysize = axheight/(1.25*nline);
                for i = 1:nline
                    ycent = axpos(2) + nline*winsize - (2*i-1)*winsize/2;  % position the zero level for the current trace
                    sliderpos = [axpos(1)-.04 ycent-sliderysize/2 min(.03, sliderysize/2) sliderysize];   %l b w h
                    h = uicontrol(fig,'Style','slider',...
                        'Units','normalized',...
                        'Position',sliderpos,...
                        'Max',1,...
                        'Min',-1,...
                        'Sliderstep',[1 1],...
                        'Value',0,...
                        'Tag',num2str(double(ax),50),...
                        'Callback', ['plot_matrix_callback(guidata(gcf),''scaley'',' num2str(i) ');']);  % the callback sends the associated axis, the function and the index
                    handles.scaley_sliders(i) = h;
                end
            otherwise
                disp('uicontrol not supported for scaling')
        end
        
    case {'scrollx'}
        % make the xscrollbar
        ytop = axpos(2)-.07;
        ybot = axpos(2)-.08;

%         realxrange = handles.sts.nsamp2 - handles.sts.nsamp1;
%         viewxrange = handles.stsPlot.nsamp2-handles.stsPlot.nsamp1;

         try  % ugly ugly hack
             [nr,nc] = size(handles.dat);  %% should be overloaded - gives the total size of the subset
         catch
             [nr,nc] = size(handles.dat.Data);  %% should be overloaded - gives the total size of the subset
         end
         
         realxrange = nr;    %handles.sts.nsamp2 - handles.sts.nsamp1;   % the total range that can be shown from this file
         viewxrange = handles.viewstop - handles.viewstart;   % the size of the current window

         nviews = realxrange/viewxrange;
        step = 1/(1.5*nviews);
        currmid = 100*(viewxrange/2)/realxrange;  % this is the position of the current midpoint, in percent
        
        xslidpos = [axpos(1) ybot axpos(3) .03];
        if currmid >= (100-currmid)
            disp('error in the range of values for the scrollbar slider')
            disp('resetting the range')
            currmid = 49;
        end
        
        handles.scrollx_slider = uicontrol(fig,'Style','slider',...
            'Units','normalized',...
            'Position',xslidpos,...
            'Max',100-currmid,...
            'Min',currmid,...
            'Sliderstep',[step/10 step],...
            'Value',currmid,...
            'Tag',num2str(double(ax),50),...
            'Callback', 'plot_matrix_callback(guidata(gcf),''scrollx'');');

            case 'playbuttons'
        set(fig,'Units','normalized');
        figpos = get(fig,'Pos');  %l b w h
        
        ytop = axpos(2)-.05;
        ybot = axpos(2)-.06;
        buttonpos = [.01 ybot (.03) .03];
        handles.stop_button = uicontrol(fig,'Style','pushbutton',...
            'Units','normalized',...
            'Position',buttonpos,...
            'Tag','stopbutton',...
            'String','x',...
            'Callback', 'plot_matrix_callback(guidata(gcf),''stopbutton'');');

        buttonpos = [.04 ybot (.06) .03];
        handles.play_button = uicontrol(fig,'Style','pushbutton',...
            'Units','normalized',...
            'Position',buttonpos,...
            'Tag','playbutton',...
            'String','>',...
            'Callback', 'plot_matrix_callback(guidata(gcf),''playbutton'');');

        buttonpos = [.01 (ybot-.03) (.045) .03];
        handles.rewind_button = uicontrol(fig,'Style','pushbutton',...
            'Units','normalized',...
            'Position',buttonpos,...
            'Tag','rewindbutton',...
            'String','<<',...
            'Callback', 'plot_matrix_callback(guidata(gcf),''rewindbutton'');');      

        buttonpos = [.055 (ybot-.03) (.045) .03];
        handles.fastforward_button = uicontrol(fig,'Style','pushbutton',...
            'Units','normalized',...
            'Position',buttonpos,...
            'Tag','fastforwardbutton',...
            'String','>>',...
            'Callback', 'plot_matrix_callback(guidata(gcf),''fastforwardbutton'');');      
        
        handles.stopflag = 0;
        handles.playspeed = .05;        
       
% all the cases below can either be associated with a mouse or the uimenu, depending on the uitype argument         
    case {'xzoom','zoomx'}
        set(gcf,'WindowButtonDownFcn','plot_matrix_callback(guidata(gcf),''zoomx'',''down'');');        
        handles = add_function(handles,control_function,uitype);
    case {'idtimes'}
        set(gcf,'WindowButtonDownFcn','plot_matrix_callback(guidata(gcf),''idtimes'',''down'');');
        handles = add_function(handles,control_function,uitype);

%     case {'select_current_trace'}
%         handles = add_function(handles,control_function,uitype);
%     % the cases below should be non-exclusive and don't affect the mouse menu
%     case {'notes'}
%         handles = add_function(handles,control_function,uitype);
%     case {'save_info'}
%         handles = add_function(handles,control_function,uitype);
%     case {'comments'}
%         handles = add_function(handles,control_function,uitype);
%     case {'filter_display'}
%         handles = add_function(handles,control_function,uitype);
        
    case 'mouse_toggle'
        switch uitype
            case 'menu'
                handles.mouse_menu = uimenu(gcf,'Label','Mouse Functions');
                for ii = 1:length(handles.mouse_functions)
                    label = handles.mouse_functions{ii};
                    callbackString = ['plot_matrix_callback(guidata(gcf),''mouse_toggle_menu'',''' label ''');'];
                    uimenu(handles.mouse_menu,'Label',label,'Callback',callbackString);
                end
                callbackString = ['plot_matrix_callback(guidata(gcf),''' label ''',''down'');'];
                set(gcf,'WindowButtonDownFcn',callbackString);
            case 'pushbutton'
                set(fig,'Units','normalized');
                figpos = get(fig,'Pos');  %l b w h

                ytop = axpos(2)-.07;
                ybot = axpos(2)-.08;
                buttonpos = [(axpos(1)+axpos(3)+.02) ybot (.075) .05];
                label = handles.mouse_functions{1};
                handles.mouse_toggle_button = uicontrol(fig,'Style','pushbutton',...
                    'Units','normalized',...
                    'Position',buttonpos,...
                    'Tag','mouse_toggle',...
                    'String',label,...
                    'Callback', 'plot_matrix_callback(guidata(gcf),''mouse_toggle_button'');');

                callbackString = ['plot_matrix_callback(guidata(gcf),''' label ''',''down'');'];
                set(gcf,'WindowButtonDownFcn',callbackString);
        end

    otherwise
        handles = add_function(handles,control_function,uitype);  % general function to allow creation of new control possibilities
 
end

guidata(gcf,handles);

function handles = add_function(handles,func_str,uitype)
switch uitype
    case 'menu'  % all of these functions should be in a menu without question - don't involve a mouse
        if isempty(handles.menu_functions)
            handles.menu_functions{1} = func_str;
            handles.menu = uimenu(gcf,'Label','Analysis Functions');
            callbackstring = ['plot_matrix_callback(guidata(gcf),''' func_str ''',''down'');'];
            uimenu(handles.menu,'Label',func_str,'Callback',callbackstring);            
        else
            nfunc = length(handles.menu_functions);
            handles.menu_functions{nfunc+1} = func_str;
            callbackstring = ['plot_matrix_callback(guidata(gcf),''' func_str ''',''down'');'];
            uimenu(handles.menu,'Label',func_str,'Callback',callbackstring);            
        end
    case 'mouse'  % this are the different functions that can be associated with the mouse
        callbackString = ['plot_matrix_callback(guidata(gcf),''' func_str ''',''down'');'];
        set(gcf,'WindowButtonDownFcn',callbackString);
        if isempty(handles.mouse_functions)
            handles.mouse_functions{1} = func_str;
        else
            nfunc = length(handles.mouse_functions);
            handles.mouse_functions{nfunc+1} = func_str;
        end
end

