function hndl = get_parafig_obj(tag)
%function hndl = get_spfig_obj(tag)
%  Function to find the handle for the desired object within PARAFIG
%  Assumes that the order of Children within the PARAPFIG is always
%  the same and then just has a lookup table. Also assumes that
%  PARAFIG is the current figure, which seems safe enough for now.
%
%  The object tags are (in the appropriate order):
%  Window:  the plotting window
%  FnameText:  the text which says 'Filename'
%  FnameEdit:  the edit box for the filename
%  PlotDensEdit:  the edit box for the density of shown spikes
%  PlotDensText:  the text which says 'plotting density'
%  XParaMenu:  the popupmenu for setting the X parameter
%  YParaMenu:  the popupmenu for setting the Y parameter
%  ZParaMenu   the popupmenu for setting the Z parameter
%  PlotXYButton:  the button for plotting X vs Y
%  PlotXYZButton  the button for plotting X vs Y vx Z
%  XText:      the Text that says X
%  YText:      the Text that says Y
%  ZText:      the Text that says Z
%  AzSlider:   the Slider to set the azimuth
%  ElSlider:   the Slider to set the elevation
%  AzText:     the Text that says azimuth
%  ElText:     the Text that says elevations
%  NewBoxButton:  the button to start specifying a new cluster box
%  ClusNumButton: the button to increment the current cluster
%  ClusIncText:   the text saying cluster number
%  ClusFreeButton: the button to delete the current cluster
%  TopEditButton:    the button for editing the top border w/mouse
%  LeftEditButton:   the button for editing the left w/mouse
%  RightEditButton:  the button for editing the right w/mouse
%  BottomEditButton: the button for editing the bottom w/mouse
%  SaveFnameEdit:  the edit box for the file to save the output
%  SaveFnameText:  the text that says Save to:
%  PrevFnameEdit:   the edit box for the file to get with previous 
%  PrevFileText:   the text box that says Previous Clusters File
%  KmnsText:      the text that says Do k-means
%  NKmnsEdit:     the edit box for setting the number of k-mns

kids = get(gcf,'Children');
kids = kids(end:-1:1);          % new objects are always added onto 

hndl = findobj(kids,'Tag',tag);
% the beginning of the list

if isempty(hndl)
    switch tag
        case 'Window'
            hndl = kids(1);
        case 'FnameText'
            hndl = kids(2);
        case 'FnameEdit'
            hndl = kids(3);
        case 'PlotDensEdit'
            hndl = kids(4);
        case 'PlotDensText'
            hndl = kids(5);
        case 'XParaMenu'
            hndl = kids(6);
        case 'YParaMenu'
            hndl = kids(7);
        case 'ZParaMenu'
            hndl = kids(8);
        case 'PlotXYButton'
            hndl = kids(9);
        case 'PLotXYZButton'
            hndl = kids(10);
        case 'XText'
            hndl = kids(11);
        case 'YText'
            hndl = kids(12);
        case 'ZText'
            hndl = kids(13);
        case 'AzSlider'
            hndl = kids(14);
        case 'ElSlider'
            hndl = kids(15);
        case 'AzText'
            hndl = kids(16);
        case 'ElText'
            hndl = kids(17);
        case 'NewBoxButton'
            hndl = kids(18);
        case 'ClusNumButton'
            hndl = kids(19);
        case 'ClusIncText'
            hndl = kids(20);
        case 'ClusFreeButton'
            hndl = kids(21);
        case 'TopEditButton'
            hndl = kids(22);
        case 'LeftEditButton'
            hndl = kids(23);
        case 'RightEditButton'
            hndl = kids(24);
        case 'BottomEditButton'
            hndl = kids(25);
        case 'SaveFnameEdit'
            hndl = kids(26);
        case 'SaveFnameText'
            hndl = kids(27);
        case 'PrevFnameEdit'
            hndl = kids(28);
        case 'PrevFnameText'
            hndl = kids(29);
        case 'KmnsText'
            hndl = kids(30);
        case 'NKmnsEdit'
            hndl = kids(31);
        otherwise
            disp('Unknown object')
    end
end
   
