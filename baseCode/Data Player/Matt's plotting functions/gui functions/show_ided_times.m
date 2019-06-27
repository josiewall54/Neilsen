function show_ided_times(ided_times,varargin)

if nargin == 1
    ax = gca;
else
    ax = varargin{1};
end

temp = findobj(ax,'Tag','idedpatch');
delete(temp)

if ~isempty(ided_times)
    npatches = size(ided_times,1);
    count = 0;
    for i = 1:npatches
        if count 
            col = [.75 1 1];
        else
            col = [.75 .75 1];
        end
        count = ~count;
        col = [.75 1 1];
        
        x1 = ided_times(i,1);
        x2 = ided_times(i,2);
        YLim   = get(ax,'Ylim');
        h_zoom = patch([x1;x1;x2;x2],[YLim';flipud(YLim')],col,...
            'Parent',ax,...
            'HitTest','off','FaceAlpha',.5);
%             'EraseMode','xor');
        set(h_zoom,'Tag','idedpatch');
    end
end

% handles = guidata(get(ax,'Parent'));
% handles.ided_times = ided_times;
% guidata(get(ax,'Parent'),handles);
