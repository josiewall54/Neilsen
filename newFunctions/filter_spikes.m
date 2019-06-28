function [rawdata, rawdata2, ind, NSD] = filter_spikes(spikedata,varargin)
%This function adds up all the spike times across all the channels and
%replaces all the values greater than a threshold, based on the specified
%standard deviation value, will be replaced by 'NaN'.
%
%   Returns the updated spikedata structure.

NSD = 5;
DISPLAY = 1;
if nargin == 2
    NSD = varargin{1};
elseif nargin == 3
    NSD = varargin{1};
    DISPLAY = varargin{2};
end

rawdata = spikedata;
ndata = length(rawdata);
nchan = size(rawdata,2);

allsptimes = zeros(ndata,1);
for ii = 1:nchan
    allsptimes = allsptimes + rawdata(:,ii);
end

% [N,binedges] = histcounts(allsptimes);
N = allsptimes;
% bin_mid = binedges(1:end-1) + binsize/2; %these are the times for the center of the bin
sd = std(N);
ind = find(N > (NSD*sd));  % the indices into the bins where there are more spikes than expected
rawdata2 = rawdata;

for iii = 1:nchan
%     rawdata(ind,iii) = mean(rawdata2(:,iii));
    rawdata(ind,iii) = 0;

end
temp = 0;



