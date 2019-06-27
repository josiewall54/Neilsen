function [samps, times] = get_view(varargin)

if nargin == 0
    ax = gca;
else
    ax = varargin{1};
end

fig = get(ax,'Parent');
handles = guidata(fig);
% samps = [handles.stsPlot.nsamp1 handles.stsPlot.nsamp2];
if ~isempty(handles)
    samps = [handles.viewstart handles.viewstop];
    ax = axis(gca);
    times = [ax(1) ax(2)];
% plottimes = handles.stsPlot.Time;
% times = samps/5000;
else
    samps = 0;
    times = 0;
end