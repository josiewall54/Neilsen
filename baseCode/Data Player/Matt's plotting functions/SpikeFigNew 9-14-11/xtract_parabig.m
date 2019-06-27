function [para, parastr] = xtract_parabig(fname,nsamp,nchan,plist)
% function [para, parastr] = xtract_parabig(fname,nsamp,nchan,plist)
%  Function to extract parameters from a large file using the 
%  parameters controls described in PLIST, such as saved from 
%  using SPFIG.  FNAME has the name of the big file, NSAMP is the
%  number of samples per spike, NCHAN is the number of channels
%  (columns) in the file.  Reads in the file piece by piece, 
%  removes the baseline of the spikes and then extracts the 
%  relevant parameters.

fid = fopen(fname,'r');
if fid == -1
   disp('bad file name')
   return
end
step = 500;  % read in 500 spikes at a time

limit = 999999;
n=0;
npara = sum(plist(:,1));  % the number of parameters
para = zeros(1,npara);
count = step*nsamp*nchan;  
while (count == step*nsamp*nchan) & (n < limit),
	[dat,count] = fscanf(fid,'%f',[nchan step*nsamp]);
   dat = dat';
   for i = 1:nchan   % remove the baseline
      temp = zeros(nsamp,count/(nchan*nsamp));
      junk = dat(:,i);
      temp(:) = junk(:);    % convert it from columns to spikes
      base = mean(temp(1:end,:));
      for j = 1:nsamp
         temp(j,:) = temp(j,:)-base;
      end
      dat(:,i) = temp(:);
   end 
   realstep = count/(nsamp*nchan);
   [Ptemp,parastr] = xtract_para(dat,plist,realstep,nsamp);
   para = [para; Ptemp];
   n = n+ step;
end	
para = para(2:end,:);
