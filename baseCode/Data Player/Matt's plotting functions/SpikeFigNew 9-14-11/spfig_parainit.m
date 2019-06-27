function parapara = spfig_parainit(nchans,nsamp)
%function paradat = spfig_parainit(nchans,nsamp)
%   Function to initialize the popupmenu of spike parameters and to
%   create the data structure within the SPDAT structure associated
%   with the figure.
%   The idea is that there are NCHANS*NPARA possible parameters.  Each
%   parametes is a row into an array.  The first columns is 1 or 0
%   depending on whether the parameter has been chosen or not.
%   The second column is the type of parameter.
%   The third column is for which channel it is extracted from.
%   The next columns give information pertinent to the particular
%   parameter.  e.g. for peak, the columns would specify the time
%   window for accepted peaks.
%   The spike parameters are (in the correct order):
%   Peak:
%   Valley:
%   Time to Peak:
%   Time to Valley:
%   Peak to Valley:
%   Amplitude Peak to Valley:
%   Spike Width
%   PCA 1
%   PCA 2
%   PCA 3
%   PCA 4

NPARA = 13;   % The current number of parameters to choose from
parapara = zeros(NPARA*nchans,10);   %  is 10 too many?
for i = 1:nchans   % defaults are obvious for now
   for j = 1:NPARA
      parapara((i-1)*NPARA+j,1:5) = [0 j i 1 nsamp];
      if ((j >7) & (j<12))
         parapara((i-1)*NPARA+j,4) = j-7;  % for pca put in the component #
      end
   end
end

% the labels for each of the parameters
str = cell(NPARA,1);
str{1} = ['Peak'];
str{2} = ['Valley'];
str{3} = ['Time to Peak'];
str{4} = ['Time to Valley'];
str{5} = ['Peak to Valley'];
str{6} = ['Time to Peak to Valley'];
str{7} = ['Spike Width'];
str{8} = ['PCA#1 '];
str{9} = ['PCA#2 '];
str{10} = ['PCA#3 '];
str{11} = ['PCA#4 '];
str{12} = ['Arb Peak1'];
str{13} = ['Arb Valley1'];
STR = '';

for i = 1:nchans
   for j = 1:NPARA
      temp = [str{j} num2str(i)'];
      STR = char(STR,temp);
   end
end
STR = STR(2:end,:);
hndl = get_spfig_obj('ParaMenu');
set(hndl,'String',STR);
set(hndl,'Value',1);

hndl = get_spfig_obj('ParaMenu');

temp = get(hndl,'String');
nitems = size(temp,1);

str = '';
for itemn = 1:nitems
    parapara(itemn,1) = 1;
    parastr = get(hndl,'String');
    str = char(str,parastr(itemn,:));
end    
str = str(2:end,:);
hndl = get_spfig_obj('ParaBox');
set(hndl,'String',str);

