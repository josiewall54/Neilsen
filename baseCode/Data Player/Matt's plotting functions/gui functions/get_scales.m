function scales = get_scales(varargin)

if nargin == 0
    ax = gca;
else
    ax = varargin{1};
end

fig = get(ax,'Parent');
handles = guidata(fig);
scales = handles.ygain;
