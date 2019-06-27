%this function calculates the mean interval (in nb of samples between two
%TTL pulses on chan 17 of file name 'filename'
function [meanInterval, minInterval, maxInterval, nIntervals, PulseSamples] = getMeanPulseInterval(obj, filename,varargin)
    bufferSize=32768;
    pulseChan=17;
    thresholdValue=2.6;
    precflag = 1;
    
    if nargin == 5
        pulseChan = varargin{1};
        thresholdValue = varargin{2};
        precflag = varargin{3};
    end
    
    %read a small portion of the data to get basic info about the file
    [info, dummy, dummy2] = readlabviewfile(filename,[1 2],1);
    nbSamples=info.ntotsamp;
    nchan = size(dummy,1);
    if nchan < 17
        disp('no sync trace');
        meanInterval =0;
        minInterval=0;
        maxInterval=0;
        nIntervals=0;
        PulseSamples=0;
        return
    end
    %pos is a vector holding the absolute position of the start of all the
    %pulses
    pos=[];
    startPos = 1;
    EoF = false;
    while ~EoF,
        endPos = startPos+bufferSize-1;
        if endPos > nbSamples,
            endPos = nbSamples;
            EoF=true;
        end
        samples = [startPos endPos];
        [dummy, data, dummy] = readlabviewfile(filename, samples, 1);
        temp=data(pulseChan, :)>thresholdValue; %pulses are == 1
        if (temp(1)==1) & precflag
            %we are in the middle(?) of a pulse, if we happen to fall on
            %the first sample of a pulse, we would miss the pulse entirely
            %let's back up 1 sample just in case
            startPos = startPos-1;
            continue
        end
        temp=diff(temp); %transition low-high==+1, high-low==-1
        temp=1+find(temp==1);%find transition low-high. 1+ to compensate 
                             %for the offset when doing the diff
        pos = cat(2, pos, (startPos-1)+temp);%concatenate with previous pos
                                             %taking into account the current
                                             %position in the file
        
        startPos = endPos+1;
%         disp(endPos)
        fprintf('.')
    end
    pos = unique(pos); %because of the backing up process, we might have
                       %duplicate positions, unique() removes them
    intervals = diff(pos); %calculate interval by taking difference
    [dummy, nIntervals] = size(pos);
    
    meanInterval = mean(intervals);
    minInterval = min(intervals);
    maxInterval = max(intervals);
    PulseSamples = pos;
end
