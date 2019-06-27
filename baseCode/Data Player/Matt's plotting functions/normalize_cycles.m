function [all_cycles, all_nsamp] = normalize_cycles(dat,nbin,varargin)

method = 'mean';
if nargin == 3
   method = varargin{1};
end
    
Ndev = 5;
ncycles = length(dat);
for ii = 1:ncycles
   allnsamp(ii) = length(dat{ii});
end
avg_nsamp = min(allnsamp);

nused = 0;
for ii = 1:ncycles
    [nsamp,nchan] = size(dat{ii});
    if nchan > nsamp
        dat{ii} = dat{ii}';
        [nsamp,nchan] = size(dat{ii});
    end
           
    if nsamp < Ndev*avg_nsamp        
        nused = nused+1;
        temp2 = zeros(nbin,nchan);
        bins = round(linspace(1,nsamp+1,nbin+1));
        for xx = 1:(nbin)
            if strcmp(method,'mean')            
                temp2(xx,:) = nanmean(dat{ii}(bins(xx):(bins(xx+1)-1),:));
            elseif strcmp(method,'integrate')                
                temp2(xx,:) = nanmean(abs(dat{ii}(bins(xx):(bins(xx+1)-1),:)));
            elseif strcmp(method,'neural_bins')
                temp2(xx,:) = nansum(dat{ii}(bins(xx):(bins(xx+1)-1),:));
            end
        end
        all_cycles(nused,:,:) = temp2;
%         disp([sum(temp2) sum(dat{ii})]);
        all_nsamp(nused) = nsamp;
    else
        disp(['skipping cycle ' num2str(ii)])
    end           
end
