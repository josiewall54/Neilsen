function paradat = parafig_divide(paradat)
%function paradat = parafig_divide(paradat)
%  Function to divide the data in paradat into each clusters specified
%  by the user or by an algorithm.  

nclus = paradat.nclus;
npara = paradat.npara;
dat = paradat.data;

% the first one is always a box which encompasses all of the data
% and should take up the remnants of everything which is not 
% clustered at the end
oldind = paradat.clusind;
paradat.clusind = ones(paradat.nspikes,1);
for i = 1:nclus
   ind = ones(size(dat,1),1);
   switch paradat.clusters(i,1)
   case 1  % It's a Box
      for j = 1:npara  % so each para has a max and min value
         mn = paradat.clusters(i,2*j);
         mx = paradat.clusters(i,2*j+1);
         ind = ind & ((dat(:,j) >= mn) & (dat(:,j) <= mx));
      end
      paradat.clusind(ind) = i;      
   case 2 % It's a K-means  and has to be done over all clusters since it's competitive
      paradat.clusind = kmeans_classify(dat,paradat.clusters(:,2:end));
      return
   case 3  % It's an ellipse
      para1 = paradat.clusters(i,2);   % these two identify which two parameters 
      para2 = paradat.clusters(i,3);   % the ellipse was defined for
      ell = paradat.clusters(i,4:13);  % the ellipse is defined by 10 elements
      ind = in_ell(ell,dat(:,[para1 para2]));   % find the assignments
      paradat.clusind(ind) = i;
   end
end
