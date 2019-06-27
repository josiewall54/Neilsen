function newdat = minmax_resample(data,new_nsamp)

[nchan,nsamp] = size(data);
step = round(nsamp/new_nsamp);

for ii = 1:nchan
    val = data(ii,:);
    if step < 1   % no downsampling is actually necessary
        step = 1;
        val2 = val';
        ind3 = 1:length(val);  % the samples that were actually used
    else
        nevensamp = floor(nsamp/step)*step;  %  the number of samples after roudning
        ind = 1:nevensamp;
        ind2 = reshape(ind',step,length(ind)/step)';  % turn the indices into a matrix
        val2 = minmax(val(ind2));  % take the minmax of each interval to be downsampled
        val2 = reshape(val2',length(val2(:)),1);   % reshape the data back to a vector
        ind3 = sort([ind2(:,1)' ind2(:,1)'+floor(step/2)]');  % the sample indices for the new samples
    end
    newdat(ii,:) = val2';
end