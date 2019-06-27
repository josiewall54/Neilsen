function paradat=para_kmns(paradat)
%function paradat=para_kmns(paradat)
%  Function to do kmeans on the current set of parameters using the 
%  data structure in parafig.  

[st,cl] = kmeans(paradat.data,paradat.nclus,2,5000);
paradat.clusind = cl';

clusters(1,:) = paradat.clusters(1,:)*0;
clusters = zeros(paradat.nclus,paradat.npara+1);
for i = 1:paradat.nclus
   clusters(i,1) = 2;  % id for k-means clusters
   for j = 1:paradat.npara
      clusters(i,j+1) = st(i,j);  % now put in the means
   end
end
paradat.clusters = clusters;
paradat.currclus = 1;