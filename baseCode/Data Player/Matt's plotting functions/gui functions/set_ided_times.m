function set_ided_times(ided_times,varargin)

if nargin == 1
    ax = gca;
else
    ax = varargin{1};
end

handles = guidata(get(ax,'Parent'));

if isa(ided_times,'cell')
    handles.all_ided_times = ided_times;
else
    handles.all_ided_times{handles.current_trace} = ided_times;
end

show_ided_times(handles.all_ided_times{handles.current_trace},ax);

guidata(get(ax,'Parent'),handles);

