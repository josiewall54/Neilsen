classdef EMGTimeSeries<SubsetTimeSeries
    
    properties
        firstPulseInFile;%first pulse onset
        pulsePeriod;%number of samples between pulse onsets
        nPulses;
        minVal; 
        maxVal;
        Pulses;
    end

    methods
        function ets= EMGTimeSeries(varargin)
            switch nargin 
             case 0 %if no input arguments, create a default object
             name = '';
             location = '';
             type = '';
             case 3 %create an object with file name, type, and location but no data   
             name = varargin{1};%name of file read
             location = varargin{2};%location of file read
             type = varargin{3};%type of file read
            end
            ets = ets@SubsetTimeSeries(name, location, type); %call to SubsetTimeSeries construct             
%             [ets.pulsePeriod, ets.minVal, ets.maxVal, ets.nPulses] = ets.getMeanPulseInterval([ets.fileLocation '\' ets.fileName ets.fileType]);
        end
 
        function ets = Setup_Pulse_Info(ets)
            temp = getFirstPulse(ets);
            ets.firstPulseInFile = temp;
            [ets.pulsePeriod, ets.minVal, ets.maxVal, ets.nPulses, ets.Pulses] = ets.getMeanPulseInterval([ets.fileLocation '\' ets.fileName ets.fileType]);
        end
        
        function firstPulseInFile = getFirstPulse(ets)
            %opens file and pulls in 1000 data points from the highest
            %channel number until it finds the first pulse (>4 is hard
            %coded!!!)
            %
            %this code assumes:
            %1)that the highest channel number is the one with the pulses 
            %2)that >4 is the pulse
            %3)that the pulse period is consistent - I did not take the first 100 pulse periods and average them!!!
            ind = 1;  % dummy for the default, so it doesn't die
            i1=1000;
            while (isempty(ind) & (i1 < 50000))
                %pulling in 1000 data points and trying to find chanData >4
                etsData = updateData(ets, 1, i1, 1);
                data = etsData.Data;
                [d1, d2] = size(data);
                chanData = data(:, d2);  % the last channel
                ind = find(chanData>4);
                i1 = i1+1000;
            end
            firstPulseInFile = ind(1);
        end
        
        function nSample = getSampleFromPulse(ets, nPulse)
            %returns a sample number from a pulse number
            if isempty(ets.firstPulseInFile)   % if it hasn't been set yet, then call it now
                ets.firstPulseInFile = getFirstPulse(ets);
                [ets.pulsePeriod, ets.minVal, ets.maxVal, ets.nPulses] = ets.getMeanPulseInterval([ets.fileLocation '\' ets.fileName ets.fileType]);
            end
            nSample = ceil((nPulse-1) * ets.pulsePeriod + ets.firstPulseInFile);
        end
        function nPulse = getPulseFromSample(ets, nSample)
            %returns a pulse number from a sample
            if isempty(ets.firstPulseInFile)   % if it hasn't been set yet, then call it now
                ets.firstPulseInFile = getFirstPulse(ets);
                [ets.pulsePeriod, ets.minVal, ets.maxVal, ets.nPulses] = ets.getMeanPulseInterval([ets.fileLocation '\' ets.fileName ets.fileType]);
            end
            nPulse = round((nSample + ets.pulsePeriod - ets.firstPulseInFile)/ets.pulsePeriod);
        end
        
        
    end
end
        