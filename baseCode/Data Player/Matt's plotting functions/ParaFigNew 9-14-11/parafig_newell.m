function paradat = parafig_newell(paradat)
%function parafig_newell(paradat)
%  Function to let the user create a new clustering ellipse.  Lets the
%  user place an ellipse over the parameters.It then sets these values
%  in the PARADAT data structure.

dat = paradat.data(:,[paradat.plotpara(1) paradat.plotpara(2)]); % this is the current data
ell = sp_ellipse3(dat');
paradat.clusters(paradat.currclus,:) = 0*paradat.clusters(1,:);
paradat.clusters(paradat.currclus,1) = 3;  % flag it as an ellipse
paradat.clusters(paradat.currclus,2:3) = paradat.plotpara(1:2);  % put in the parameters for which the ellipse is defined
paradat.clusters(paradat.currclus,4:13) = ell;  % put in the ellipse
