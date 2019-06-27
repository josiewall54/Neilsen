function sts = updateDataHack(stsIn, varargin) %reads data from file 
 sts = stsIn;  
    switch nargin-1
            case 0
                nsamp1 = 1;
                nsamp2 = Inf;
                downSample = 1;
            case 1 
                nsamp1 = varargin{1};
                nsamp2 = Inf;
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
                    
            
            
            sts = set(sts, 'nsamp1', nsamp1); %index of first number to be read from file
            sts = set(sts, 'nsamp2', nsamp2); %index of last number to be read from file
            sampleRange = [nsamp1 nsamp2]; %create sampleRange as expected by readlabviewfile
            sts = set(sts, 'downSample', downSample); %number of samples to skip between samples read in from the file
            [info, dat, time] = readlabviewfile(sts.fileName, sampleRange, downSample); %call to readlabviewfile which returns data, time info, and information from the file header
            sts = set(sts, 'Data', dat, 'Time', time); %sets data and time attributes (timeseries method)
end