function parafig_replot(paradat)
%function parafig_replot(paradat)
%  Function to replot the current window after a change has occurred
%  It should also plot the data according the clustering scheme.

col = char('b.','r.','m.','c.','g.','y.','k.','bx','rx','mx','cx','gx','yx','kx');

% replot the data with different colors for each cluster
hold off
nshow = paradat.nspikes*paradat.plotdens/100;
showind = 1:round(paradat.nspikes/nshow):paradat.nspikes;
xind = paradat.plotpara(1);
yind = paradat.plotpara(2);
zind = paradat.plotpara(3);
dat = paradat.data;
nclus = paradat.nclus;
plot(0,0);
if paradat.plotpara(3) == 0
   for i = 1:nclus
      ind = find(paradat.clusind(showind) == i);
      plot(dat(showind(ind),xind),dat(showind(ind),yind),col(i,:));
      hold on
   end
else
   for i = 1:nclus
      ind = find(paradat.clusind(showind) == i);
      plot3(dat(showind(ind),xind),dat(showind(ind),yind),dat(showind(ind),zind),col(i,:));
      hold on
   end
   grid
   hndl = get_parafig_obj('AzSlider');
   az =get(hndl,'Value');
   hndl = get_parafig_obj('ElSlider');
   el = get(hndl,'Value');
   view(az,el);   
end

% and show the boundaries for the currently selected cluster
hold on

curr = paradat.currclus;
switch paradat.clusters(curr,1)
    case 1     % boxes
        left = paradat.clusters(curr,xind*2);
        right = paradat.clusters(curr,xind*2+1);
        bottom = paradat.clusters(curr,yind*2);
        top = paradat.clusters(curr,yind*2+1);
        x = [left right right left left];
        y = [bottom bottom top top bottom];
        plot(x,y,col(curr))
    case 2     % k-means
        x = paradat.clusters(curr,xind+1);  % pick out the relevant
        y = paradat.clusters(curr,yind+1);  % means
        xcol = col(curr);
        xcol = ['k*'];
        plot(x,y,xcol);
        
end
set(gca,'ButtonDownFcn','parafig(''AxesButtonDown'')'); % have this always be active
hold off