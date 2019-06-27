function set_scales(scale,varargin)

if nargin == 1
    ax = gca;
else
    ax = varargin{1};
end

fig = get(ax,'Parent');
handles = guidata(fig);

nchan = length(handles.linehandles);
if length(scale) ~= nchan
    disp('wrong number of scales sent in');
else
    handles.ygain = .5./scale;
    handles = replot_data(handles);
    guidata(fig,handles);
end

