function cycles = extract_cycledata(data,onsets)

NCYCLES = length(onsets);

nsamp = diff(onsets,1,2);
cycles = NaN*zeros(NCYCLES,max(nsamp)+1);

for ii = 1:NCYCLES
    ind = onsets(ii,1):onsets(ii,2);
    cycles(ii,1:(nsamp(ii)+1)) = data(ind);
end
    