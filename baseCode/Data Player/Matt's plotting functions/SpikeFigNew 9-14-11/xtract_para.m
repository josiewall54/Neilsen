function [para,parastr] = xtract_para(aps,plist,nsp,nsamp)
%function [para,labels] = xtract_para(aps,plist,nsp,nsamp)
%  Function to extract parameters from a set of action potentials.
%  Uses conventions specified in SP_PARA_INIT.

npara = size(plist,1);
usedind = find(plist(:,1)==1);
para = zeros(nsp,length(usedind));
nchans = size(aps,2);
for i = 1:nchans   % change the data from a vector to a matrix
   temp = zeros(nsamp,nsp);
   junk = aps(:,i);
   temp(:) = junk(:);
   datarr{i} = temp;
end
parastr = '';
lastch = 0;
for i = 1:(length(usedind))
   ch = plist(usedind(i),3);  % the channel number
   t1 = plist(usedind(i),4);  % the first time to consider
   t2 = plist(usedind(i),5);  % the last time to consider   
   v1 = plist(usedind(i),6);  % the voltage crossing for width   
   switch plist(usedind(i),2)  % the type of parameter
   case 1   % it's a Peak
      para(:,i) = max(datarr{ch}(t1:t2,:))';
      parastr = char(parastr,['Peak' num2str(ch)]);
   case 2   % it's a Valley
      para(:,i) = min(datarr{ch}(t1:t2,:))';
      parastr = char(parastr,['Valley' num2str(ch)]);
   case 3 % it's Time to Peak
      [mx,ind] = max(datarr{ch}(t1:t2,:));
      para(:,i) = ind';
      parastr = char(parastr,['Time to Peak' num2str(ch)]);
   case 4 % it's Time to Valley
      [mn,ind] = min(datarr{ch}(t1:t2,:));
      para(:,i) = ind';
      parastr = char(parastr,['Time to Valley' num2str(ch)]);
   case 5 % it's Peak to Valley
      [mx,ind] = max(datarr{ch}(t1:t2,:));
      [mn,ind] = min(datarr{ch}(t1:t2,:));
      para(:,i) = mx'-mn';
      parastr = char(parastr,['Peak to Valley' num2str(ch)]);
   case 6   %it's time peak to valley
      [mx,mxind] = max(datarr{ch}(t1:t2,:));
      [mn,mnind] = min(datarr{ch}(t1:t2,:));
      para(:,i) = mnind'-mxind';
      parastr = char(parastr,['Time Peak to Valley' num2str(ch)]);
   case 7   % it's spike width
      [mx,mxind] = max(datarr{ch}(t1:t2,:));  % find the peak
      tind = t1:t2;
      w1 = zeros(1,nsp); w2 = zeros(1,nsp);
      for j = 1:length(tind)  %iterate through the samples
         ind = (datarr{ch}(tind(j),:) > v1);
         w1((ind == 1) & (w1 == 0)) = tind(j);  % anything greater than v1 and undefined, make it t1
         w2((ind == 1)) = tind(j);  % just keep putting the times into the second time 
      end
      para(:,i) = w2' - w1';
      parastr = char(parastr,['Spike Width' num2str(ch)]);
   case {8,9,10,11}  % it's pca   
      if ch ~= lastch  % only repeat pca if it's a new channel
         [pc,sc] = princomp(datarr{ch}');
         lastch = ch;
      end
      para(:,i) = sc(:,t1);
      parastr = char(parastr,['PCA#' num2str(t1) ' ' num2str(ch)]);
   case 12   % it's an arbitrary Peak
      para(:,i) = max(datarr{ch}(t1:t2,:))';
      parastr = char(parastr,['Arb Peak' num2str(ch)]);
   case 13   % it's an arbitrary Valley
      para(:,i) = min(datarr{ch}(t1:t2,:))';
      parastr = char(parastr,['Arb Valley' num2str(ch)]);

   
   end
end

parastr = parastr(2:end,:);
disp('done extracting')