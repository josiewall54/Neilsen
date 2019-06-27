function compchan=xcorrchan(sampledata,windowsize)
%function compchan=xcorrchan(sampledata,windowsize)
%sample data is subset of data to use as an example for xcorr. 1 minuteish.
%windowsize is time+/-time t to see if same stim is felt, but sl off time
[nchan,nsamp]=size(sampledata);
compchan=zeros(nchan,nchan);
for i=1:nchan
    for j=1:nchan
        compchan(i,j)=max(abs(xcorr(sampledata(i,:),sampledata(j,:),windowsize,'coeff')));
    end
end
% disp(compchan)
% imagesc(compchan)
% end