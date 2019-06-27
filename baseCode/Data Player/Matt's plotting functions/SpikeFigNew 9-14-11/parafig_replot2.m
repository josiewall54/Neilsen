function parafig_replot(paradat)
%function parafig_replot(paradat)
%  Function to replot the current window after a change has occurred

col = ['b' 'r' 'm' 'c'];
% first replot the data
hold off
nshow = paradat.nspikes*paradat.plotdens/100;
showind = 1:round(paradat.nspikes/nshow):paradat.nspikes;
xind = paradat.plotpara(1);
yind = paradat.plotpara(2);
zind = paradat.plotpara(3);
dat = paradat.data;
if paradat.plotpara(3) == 0
   plot(dat(showind,xind),dat(showind,yind),'.');
else
   plot3(dat(showind,xind),dat(showind,yind),dat(showind,zind),'.');
   hndl = get_parafig_obj('ElSlider');
   el = get(hndl,'Value');
   hndl = get_parafig_obj('AzSlider');
   az = get(hndl,'Value');
   view(el,az);
   grid
end

hold on
