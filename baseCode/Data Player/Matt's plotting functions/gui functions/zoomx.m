function handles = zoomx(handles,action)
    ax = handles.axishandle;

    fig = gcbf;   % keep track of which figure the action took place in
    currfig = get(ax,'Parent');  % keep the figure in which the current axis is located
    switch action
        case 'down'   
            selType = get(fig,'SelectionType');
            currPt  = get(ax,'CurrentPoint');

            if strcmp(selType,'normal')    % zoom in (left mouse) - % this just starts the patch - no replotting necessary
                xlim = get(gca,'Xlim');   % the current xrange of the axis
                ylim = get(gca,'Ylim');
                xv = [xlim(1) xlim(1) xlim(2) xlim(2)];
                yv = [ylim(1) ylim(2) ylim(2) ylim(1)];
                if inpolygon(currPt(1,1),currPt(1,2),xv,yv)  % don't start the patch unless they're on the axis
                    YLim   = get(ax,'Ylim');
                    h_zoom = findobj(ax,'Tag','zoomxpatch');
                    if ~isempty(h_zoom)
                        delete(h_zoom);
                    end
                    h_zoom = patch(currPt(1,1)*[1;1;1;1],[YLim';flipud(YLim')],[1 1 .75],...
                        'Parent',ax,'FaceAlpha',.5);
%                         'EraseMode','xor');
                    set(h_zoom,'Tag','zoomxpatch');
                    set(currfig,'WindowButtonMotionFcn','plot_matrix_callback(guidata(gcf),''zoomx'',''motion'');')
                end
                
            elseif strcmp(selType,'open')  % zoom all the way out (double click)
                xlim = get(ax,'Xlim');   % the current xrange of the axis
                ylim = get(ax,'Ylim');
                xv = [xlim(1) xlim(1) xlim(2) xlim(2)];
                yv = [ylim(1) ylim(2) ylim(2) ylim(1)];
                if inpolygon(currPt(1,1),currPt(1,2),xv,yv)  % don't zoom out unless they're double clicking on the axis

                    handles.viewstart = 1;
                    handles.viewstop = size(handles.dat,1);   % this is a hack - assumes that the view will always start at the first sample
%                     handles.stsPlot.nsamp1 = handles.sts.nsamp1;
%                     handles.stsPlot.nsamp2 = handles.sts.nsamp2;
                    handles = replot_data(handles);

                    set(currfig,'WindowButtonMotionFcn','',...
                        'WindowButtonUpFcn','',...
                        'WindowButtonDownFcn','plot_matrix_callback(guidata(gcf),''zoomx'',''down'');');
                end
            elseif strcmp(selType,'alt')	% zoom out (right mouse)
                h_zoom = findobj(ax,'Tag','zoomxpatch');
                
                width = handles.viewstop - handles.viewstart;
                newmidpoint = mean([handles.viewstop handles.viewstart]);
                newwidth = 2*width;
                handles.viewstart = round(newmidpoint  - width);
                handles.viewstop = round(newmidpoint + width);

                handles = replot_data(handles);
                                
                set(currfig,'WindowButtonMotionFcn','',...
                    'WindowButtonUpFcn','',...
                    'WindowButtonDownFcn','plot_matrix_callback(guidata(gcf),''zoomx'',''down'');');
            end

        case 'motion'  % this just changes the edge of the patch - no replotting necessary
            currPt  = get(ax,'CurrentPoint');
            h_zoom = findobj(ax,'Tag','zoomxpatch');
            xdata = get(h_zoom,'XData');
            if ~isempty(xdata)
                startX = xdata(1);
                set(h_zoom,'XData',[startX*[1;1];currPt(1,1)*[1;1]]);
                set(currfig,'WindowButtonUpFcn','plot_matrix_callback(guidata(gcf),''zoomx'',''up'');',...
                    'WindowButtonDownFcn','')
            end
%             disp(xdata(1,1))
        case 'up'
            h_zoom = findobj(ax,'Tag','zoomxpatch');
      
            xlim = get(ax,'XLim');
            trange = xlim(2) - xlim(1);         
            xrange = handles.viewstop - handles.viewstart;
                      
            xdata = get(h_zoom,'XData');  % these aren't in terms of samples but times !!
            delete(h_zoom)

            %  the xdata are in terms of the times on the x axis, not in
            %  terms of sample numbers - so I need to find the times that
            %  are the closest to the ones selected by the user
            % get the sample numbers by proportions           
            if ~isempty(xdata)
                nsamp1 = round(xrange/trange*(xdata(1) - xlim(1)) + handles.viewstart);
                nsamp2 = round(xrange/trange*(xdata(3) - xlim(1)) + handles.viewstart);
            else
                nsamp1 = handles.viewstart;
                nsamp2 = handles.viewstop;
            end
%             times = stsPlot.Time;    % these are the times in hte current plot
%             [mn, ind1] = (min(abs(xdata(1) - times)));   % find the closest to the first edge of the patch
%             [mn, ind2] = (min(abs(xdata(3) - times)));   % find the closest to the second edge of the patch
%             xdata = stsPlot.nsamp1+[ind1 ind2]*stsPlot.downSample;  % this converts the indices into sample numbers
%             
%             stsPlot.nsamp1 = max(min([xdata xlim(2)-.1]), xlim(1));    % make sure that the samples are within the current window bounds
%             stsPlot.nsamp2 = min(max([xdata xlim(1)+.1]), xlim(2));

             handles.viewstart = min([nsamp1 nsamp2]);
             handles.viewstop = max([nsamp1 nsamp2]);
             handles = replot_data(handles);

            set(currfig,'WindowButtonMotionFcn','',...
                'WindowButtonUpFcn','',...
                'WindowButtonDownFcn','plot_matrix_callback(guidata(gcf),''zoomx'',''down'');');

    end
        
