function handles = idtimes(handles,action)
ax = handles.axishandle;

fig = gcbf;   % keep track of which figure the action took place in
currfig = get(ax,'Parent');
switch action
    case 'down'   % a button was pressed down
        selType = get(gcbf,'SelectionType');
        currPt  = get(gca,'CurrentPoint');

        if strcmp(selType,'normal')   % left click
            h_zoom = findobj(ax,'Tag','idtimespatch');  % this one is currently being edited
            h_ided = findobj(ax,'Tag','idedpatch');          % these are the ones that have already been created
            % if there's no current patch, see if it's on an existing patch
            if ~isempty(h_ided) & isempty(h_zoom)  % see if the click is on an existing idedpatch
                for i = 1:length(h_ided)
                    vert = get(h_ided(i),'Vertices');
                    if inpolygon(currPt(1,1),currPt(1,2),vert(:,1),vert(:,2))    % see if they clicked inside a patch
                        set(h_ided(i),'Tag','idtimespatch');    % make the one they clicked in the one being edited
                        set(h_ided(i),'FaceColor',[1 .75 1]);    % change its color
                        set(currfig,'WindowButtonMotionFcn','plot_matrix_callback(guidata(gcf),''idtimes'',''up'');')
                        return    % they pressed inside an existing patch, so return
                    end
                end
            end

            if ~isempty(h_zoom)        % if there's a current patch then edit it
                xdata = get(h_zoom,'XData');
                if ~isempty(xdata)
                    xdata = sort(xdata);
                    startX = xdata(1);
                    stopX = xdata(end);
                    dxleft = abs(currPt(1,1)-startX);   % find which border is closer
                    dxright = abs(currPt(1,1)-stopX);
                    if dxleft < dxright  % it near the left border so change it
                        set(h_zoom,'XData',[currPt(1,1)*[1;1];stopX(1,1)*[1;1]])
                    else   % its near the right border
                        set(h_zoom,'XData',[startX*[1;1];currPt(1,1)*[1;1]])
                    end
                end
            else    % if there's no patch, then create new one
                YLim   = get(ax,'Ylim');
                h_zoom = patch(currPt(1,1)*[1;1;1;1],[YLim';flipud(YLim')],[1 .75 1],...
                    'Parent',ax,...
                    'HitTest','off','FaceAlpha',.5);
                set(h_zoom,'Tag','idtimespatch');
                set(currfig,'WindowButtonMotionFcn','plot_matrix_callback(guidata(gcf),''idtimes'',''motion'');')
            end

        elseif strcmp(selType,'open')	% delete patch if it's there out (double click)
            h_zoom = findobj(ax,'Tag','idtimespatch');   % find the one being currently edited
            if ~isempty(h_zoom)
                delete(h_zoom);
            end            
            handles.all_ided_times{handles.current_trace} = get_ided_times(ax);

        elseif strcmp(selType,'alt')  % accept the cut as defined by the patch (right button)
            h_zoom = findobj(ax,'Tag','idtimespatch');   % find the one being edited
            if ~isempty(h_zoom)        % if there is one, cut the data and create new
                set(h_zoom,'Tag','idedpatch'); % change the status of the patch to edited
                set(h_zoom,'FaceColor',[.75 1 1]);  % and change the color
            end
            handles.all_ided_times{handles.current_trace} = get_ided_times(ax);
        end

    case 'motion'  % the mouse is moving across the screen
        currPt  = get(gca,'CurrentPoint');
        h_zoom = findobj(ax,'Tag','idtimespatch');
        xdata = get(h_zoom,'XData');
        if ~isempty(xdata)
            startX = xdata(1);
            set(h_zoom,'XData',[startX*[1;1];currPt(1,1)*[1;1]])
            set(currfig,'WindowButtonUpFcn','plot_matrix_callback(guidata(gcf),''idtimes'',''up'');',...
                'WindowButtonDownFcn','')
        end
        
    case 'up'   % they've released the mouse button
        currPt  = get(gca,'CurrentPoint');
        h_zoom = findobj(ax,'Tag','idtimespatch');  % find the patch being edited
        xdata = get(h_zoom,'XData');
        if ~isempty(xdata)
            startX = xdata(1);
            xlim    = sort([startX currPt(1,1)]);
            set(currfig,'WindowButtonMotionFcn','',...
                'WindowButtonUpFcn','',...
                'WindowButtonDownFcn','plot_matrix_callback(guidata(gcf),''idtimes'',''down'');',...
                'WindowButtonUpFcn','');
        end
end

