function hndl = get_spfig_obj(tag)
%function hndl = get_spfig_obj(tag)
%  Function to find the handle for the desired object within SPFIG.
%  Assumes that the order of Children within the SPFIG is always the
%  same and then just has a lookup table. Also assumes that SPFIG is
%  the current figure, which seems safe enough for now.
%
%  The object tags are (in the appropriate order):
%  Window:  the plotting window
%  FnameText:  the text which says 'Filename'
%  FnameEdit:  the edit box for the filename
%  NsampText:  the text which says 'Nsamp/sp'
%  NsampEdit:  the edit box for the nsamp
%  ChanButton: the pushbutton for showing the next channel 
%  ShowText:   the text which says 'Showing' next to the ChanButton
%  PlotDensEdit:  the edit box for the density of shown spikes
%  PlotDensText:  the text which says 'plotting density'
%  ParaMenu:    the popup menu for possible spike parameters
%  AddParaButton:  the pushbutton for adding the current parameter
%  DelParaButton:  the pushbutton for removing the current parameter
%  AllButton:   the pushbutton to show all channels or one channel
%  RmBaseButton:   the pushbutton to remove the baseline
%  ParaBox:     the box for the chosen parameters
%  ParaFnameText:  the text that says 'filename for parameters'
%  ParaFnameEdit:  the edit box for entering filename for parameters
%  ClusFileEdit:   the edit box for entering a clustering index
%  ShowClusButton: the button to spawn windows showing clusters
%  P1Button:    the button to set the value of the 1st control para
%  P2Button:    the button to set the value of the 2nd control para
%  SaveListEdit: the edit box for setting a file to save the list
%  SaveListText:  the text that says save para list


kids = get(gcf,'Children');
kids = kids(end:-1:1);          % new objects are always added onto 
                                % the beginning of the list
switch tag
case 'Window'
   hndl = kids(1);   
case 'FnameText'
   hndl = kids(2);
case 'FnameEdit'
   hndl = kids(3);
case 'NsampText'
   hndl = kids(4);
case 'NsampEdit'
   hndl = kids(5);
case 'ChanButton'
   hndl = kids(6);
case 'ShowText'
   hndl = kids(7);
case 'PlotDensEdit'
   hndl = kids(8);
case 'PlotDensText'
   hndl = kids(9);
case 'ParaMenu'
   hndl = kids(10);
case 'AddParaButton'
   hndl = kids(11);
case 'DelParaButton'
   hndl = kids(12);
case 'AllButton'
   hndl = kids(13);
case 'RmBaseButton'
   hndl = kids(14);
case 'ParaBox'
   hndl = kids(15);
case 'ParaFnameText'
   hndl = kids(16);
case 'ParaFnameEdit'
   hndl = kids(17);
case 'ClusFileEdit'
   hndl = kids(18);
case 'ShowClusButton'
   hndl = kids(19);
case 'P1Button'
   hndl = kids(20);
case 'P2Button'
   hndl = kids(21);
case 'SaveListEdit'
   hndl = kids(22);
case 'SaveListText'
   hndl = kids(23);   
otherwise 
   disp('Unknown object')
end

   