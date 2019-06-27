function splitbigfile(fname,nsamp,nchan,nspikes)
% function splitbigfile(fname,nsamp,nchan,nspikes)
%  Function to split up a big waveform file into smaller, manageable files.
%  Takes the file in FNAME, with NCHAN and NSAMP per spike, and splits it
%  into files with NSPIKES in each.  It also looks for the timestamp file
%  and splits it up as well

fid = fopen(fname,'r');
if fid == -1
   disp('bad file name')
   return
end

sfname = strtok(fname,'.');
str = ['load ' sfname '.ts'];
eval(str);
sfname = strtok(fname(end:-1:1),'\');
sfname = sfname(end:-1:1);
sfname = strtok(sfname,'.');
if length(str2num(sfname(1)))
   sfname = ['X' sfname];
end
str = ['tempts =' sfname ';'];
eval(str);

limit = 999999;
n=0;
count = nspikes*nsamp*nchan;  
while (count == nspikes*nsamp*nchan) & (n < limit),
	[dat,count] = fscanf(fid,'%f',[nchan nspikes*nsamp]);
   dat = dat';
   n = n + 1;   
   realstep = count/(nsamp*nchan);
   sfname = strtok(fname(end:-1:1),'\');
   sfname = sfname(end:-1:1);
   sfname = strtok(sfname,'.');
   str = ['save ' sfname num2str(n) '.sep dat -ascii'];
   eval(str);
   t1 = ((n-1)*nspikes+1);
   ts = tempts(t1:(t1+realstep-1));
   str = ['save ' sfname num2str(n) '.ts ts -ascii'];
   eval(str);
end	
