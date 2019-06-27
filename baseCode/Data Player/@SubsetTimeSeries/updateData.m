function sts = updateData(stsIn, varargin) %reads data from file
sts = stsIn;
downmeth = 'minmax';
% downmeth = 'default';

switch nargin-1
    case 0
        nsamp1 = stsIn.nsamp1;
        nsamp2 = stsIn.nsamp2;
        downSample = 1;
    case 1
        nsamp1 = varargin{1};
        nsamp2 = stsIn.nsamp2;
        downSample = 1;
    case 2
        nsamp1 = varargin{1};
        nsamp2 = varargin{2};
        downSample = 1;
    case 3
        nsamp1 = varargin{1};
        nsamp2 = varargin{2};
        downSample = varargin{3};
end
sts.nsamp1 = nsamp1;
% sts = set(sts, 'nsamp1', nsamp1); %index of first number to be read from file
sts = set(sts, 'nsamp2', nsamp2); %index of last number to be read from file
sampleRange = [nsamp1 nsamp2]; %create sampleRange as expected by readlabviewfile
sts = set(sts, 'downSample', downSample); %number of samples to skip between samples read in from the file

if strcmp(downmeth, 'minmax')   % if using minmax, then read all the data and downsample in second step
    [info, dat, times] = readlabviewfile([sts.fileLocation '\' sts.fileName sts.fileType], round(sampleRange), 1); %call to readlabviewfile which returns data, time info, and information from the file header
    [nchan,nsamp] = size(dat);  % the actual number of data points in the data
    step = downSample*2;   % the number of data samples to skip - doubled because each sample needs both min and max

    for ii = 1:nchan
        val = dat(ii,:);
        if step < 4   % no downsampling is actually necessary
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
%             val2((end+1):(end+2)) = minmax(val(nevensamp:end));  % pull out the last samples
%             ind3((end+1):(end+2)) = [nevensamp+floor((nsamp-nevensamp)/2) nsamp];
        end
        newdat(:,ii) = val2;
        newtimes = times(ind3);
    end
else
    [info, newdat, newtimes] = readlabviewfile([sts.fileLocation '\' sts.fileName], round(sampleRange), downSample); %call to readlabviewfile which returns data, time info, and information from the file header
    newdat = newdat';
end

sts = set(sts, 'Data', newdat(:,sts.channels2use), 'Time', newtimes); %sets data and time attributes (timeseries method) - update with new times/data

