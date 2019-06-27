function [new_dat, all_nsamp] = normalize_cyclesNaN_v2(dat,oldtimes,new_nsamp)

[MAXNSAMP,NCYCLES] = size(dat);

nused = 0;
for ii = 1:NCYCLES
    ind = find(~isnan(dat(:,ii)));
    nsamp = length(ind);
%     temp = [dat(ind(1),ii)*ones(10,1); dat(ind,ii); dat(ind(end),ii)*ones(10,1)];
    temp = dat(ind(1:end),ii);
    off = .5*(temp(1) + temp(end));
    temp2 = resample(temp-off,new_nsamp,nsamp,3);
    inds = find(oldtimes(ii,:) ~=0);
    oldt = oldtimes(ii,inds);
    newt = linspace(oldt(1),oldt(end),new_nsamp);
    temp2 = interp1(oldt,temp,newt);
    
    new_dat(:,ii) = temp2;  %+off;
    all_nsamp(ii) = nsamp;
end
