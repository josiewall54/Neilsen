function labels = get_labels(varargin)

if nargin == 0
    ax = gca;
else
    ax = varargin{1};
end

fig = get(ax,'Parent');
handles = guidata(fig);
labels = handles.labels;
