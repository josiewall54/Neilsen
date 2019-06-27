function set_notes(notes,varargin)

if nargin == 2
    ax = varargin{1};
else
    ax = gca;
end

handles = guidata(ax);
handles.notes = notes;
guidata(ax,handles);
