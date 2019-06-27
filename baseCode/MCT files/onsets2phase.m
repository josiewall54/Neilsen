function allphases = onsets2phase(onsets,totalsamp)

ncycles = size(onsets,1);

allphases = [];
allphases = NaN*zeros(totalsamp,1);
for ii = 1:ncycles
    ind = onsets(ii,1):onsets(ii,2);
    nsamp = length(ind);
    allphases(ind) = linspace(0,2*pi,nsamp);
end