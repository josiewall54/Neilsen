function [realRs, fakeRs, pval] = calc_Rs(data,niter)

[ncyc,nsamp] = size(data);

phase = linspace(-pi,pi,nsamp);
allcos = repmat(cos(phase),ncyc,1).*data;
allsin = repmat(sin(phase),ncyc,1).*data;

meancos = sum(allcos')./sum(data,2)';
meansin = sum(allsin')./sum(data,2)';

allmeanang = atan2((meansin),(meancos));

meanang = atan2(mean(meansin),mean(meancos));

realRs = sqrt(meancos.^2 + meansin.^2);

for i = 1:niter
    junk = unifrnd(0,1,1,nsamp);
    [junk,sortind] = sort(junk);
    
    allcos = repmat(cos(phase),ncyc,1).*data(:,sortind);
    allsin = repmat(sin(phase),ncyc,1).*data(:,sortind);

    meancos = sum(allcos')./sum(data,2)';
    meansin = sum(allsin')./sum(data,2)';
    fakeRs(i,:) = sqrt(meancos.^2 + meansin.^2);  
end

for ii = 1:ncyc
    ind = find(fakeRs(:,ii) > realRs(ii));
    pval(ii) = length(ind)/niter;
end