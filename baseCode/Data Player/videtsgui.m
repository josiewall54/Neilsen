function videtsgui(x,z)

f = figure('Visible','off','Position',[360,500,450,285]);

% Initialize the GUI.
% Change units to normalized so components resize 
% automatically.
set(f,'Units','normalized');
%Create a plot in the axes.
multiplePlots(x,z)
% Assign the GUI a name to appear in the window title.
set(f,'Name','Rat Video-EMG GUI')
% Move the GUI to the center of the screen.
movegui(f,'center')
% Make the GUI visible.
set(f,'Visible','on');

end