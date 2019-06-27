function paradat = parafig_newclus(paradat)
%function parafig_newclus(paradat)
%  Function to let the user create a new cluster box.  Lets the
%  User place a box on the current (2D) window using the mouse to 
%  set a rubberband box.  It then sets these values in the PARADAT
%  data structure.

k = waitforbuttonpress;
point1 = get(gca,'CurrentPoint');
finalRect = rbbox;
point2 = get(gca,'CurrentPoint');
point1 = point1(1,1:2);
point2 = point2(1,1:2);
p1 = min(point1,point2);
offset = abs(point1-point2);
left = p1(1);
right = p1(1)+offset(1);
bottom = p1(2);
top = p1(2) + offset(2);

px = paradat.plotpara(1);  py = paradat.plotpara(2);
paradat.clusters(paradat.currclus,:) = paradat.clusters(1,:);
paradat.clusters(paradat.currclus,1) = 1;
paradat.clusters(paradat.currclus,[px*2 px*2+1]) = [left right]; 
paradat.clusters(paradat.currclus,[py*2 py*2+1]) = [bottom top]; 
