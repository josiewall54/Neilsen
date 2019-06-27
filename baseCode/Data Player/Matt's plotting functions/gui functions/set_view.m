function set_view(samps,varargin)

if nargin == 1
    ax = gca;
    method = 'indices';
elseif nargin == 2
    ax = varargin{1};
    method = 'indices';
else
    ax = varargin{1};
    method = varargin{2};
end

fig = get(ax,'Parent');
handles = guidata(fig);

if strcmp(method,'times')  % this is currently assuming that  
    time = get(handles.dat,'time');
    [closest,closest_ind] = find_closest_time(time,samps(1));
    samps(1) = closest_ind;
    [closest,closest_ind] = find_closest_time(time,samps(2));
    samps(2) = closest_ind;
end

handles.viewstart = samps(1);
handles.viewstop = samps(2);
handles.stsPlot.nsamp1 = samps(1);
handles.stsPlot.nsamp2 = samps(2);
handles = replot_data(handles);
guidata(fig,handles);
