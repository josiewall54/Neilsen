function set_labels(labels,varargin)

if nargin == 1
    ax = gca;
else
    ax = varargin{1};
end

fig = get(ax,'Parent');
handles = guidata(fig);

nchan = length(handles.linehandles);
if length(labels) ~= nchan
    disp('wrong number of labels sent in');
else
    handles.labels = labels;
    handles = replot_data(handles);
    guidata(fig,handles);
end

