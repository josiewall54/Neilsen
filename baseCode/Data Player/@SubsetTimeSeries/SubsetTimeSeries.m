classdef SubsetTimeSeries < mytimeseries
%UNTITLED1 Summary of this class goes here

   %Subset Time Series Properties
   properties 
       %file information
       fileName; %name of file read
       fileLocation; %location of file read;
       fileType; %type of file read
       %data information
       totNumSamples; %total number of samples
%        dataInfo; %info pulled from the header of the file
       period;
       %sample information
       nsamp1; %index of first sample to be read from file
       nsamp2; %index of last sample to be read from file
       downSample; %number of samples to skip between samples       
       nchan;  % the number of channels to use
       channels2use;  % the channel indices from the file to actually deal with
   end

   methods
      function sts = SubsetTimeSeries(varargin) 
         switch nargin 
             case 0 %if no input arguments, create a default object
             name = '';
             location = '';
             type = '';
             case 3 %create an object with file name, type, and location but no data   
             name = varargin{1};
             location = varargin{2};
             type = varargin{3};
         end
         sts = sts@mytimeseries(); %call to timeseries construct
         sts.fileName = name; %assign variable fileName
         sts.fileLocation = location; %assign variable fileLocation
         sts.fileType = type; %assign variable fileType
         [sts.dataInfo, sts.period, sts.totNumSamples]= sts.getDataInfo([location '\' name type]);
         set(sts,'dataInfo',sts.dataInfo);  % put the structure in the timesereis object
         sts.downSample = 1;
         sts.nchan = sts.dataInfo.nchan;
         sts.channels2use = 1:(sts.nchan);
         sts.nsamp1 = 1;
         sts.nsamp2 = sts.totNumSamples;
      end

      function [dataInfo, period, totNumSamples] = getDataInfo(ets, name) %get info from the header of the file          
            %call to readlabviewfile which returns data, time info, and
            %information from the file header but really only interested in
            %info so only pulls in a couple of data points just to gain access to header 
            %containing info
            [info, dat, time] = readlabviewfile(name, [1 2]);
            dataInfo = info; %information about the experiement
            period = 1/info.samprate; %period calculated from sample rate associated with experiment
            totNumSamples = info.ntotsamp; %total number of samples assoicated with experiment
      end
      
      function sts = subsind(stsIn, nsamp1In, nsamp2In, downSampleIn) %choose view based on index and assign nasamp1, nsamp2, and downsample
          sts = stsIn; 
          sts = getDataInfo(sts);%call to getDataInfo which returns object after assigning period and dataInfo
          sts.nsamp1 = max(1,floor(nsamp1In)); %assign nsamp1
          sts.nsamp2 = min(sts.totNumSamples,ceil(nsamp2In)); %assign nsamp2
          sts.downSample = downSampleIn; %assign downsample
      end
      
      function sts = substime(stsIn, nsamp1TimeIn, nsamp2TimeIn,downSampleTimeIn) %choose view based on time and assign nasamp1, nsamp2, and downsample
          sts = stsIn;
          sts = getDataInfo(sts); %call to getDataInfo which returns object after assigning period and dataInfo
          sts.nsamp1 = max(1,floor(nsamp1TimeIn/sts.period)); %assign nsamp1
          sts.nsamp2 = min(sts.totNumSamples,ceil(nsamp2TimeIn)/sts.period); %assign nsamp2
          sts.downSample = downSampleTimeIn/sts.period; %assign downsample
      end
      
      function nSample = getSampleFromTime(sts, time)
          %returns a sample number from a time value
          nSample = ceil(time/sts.period);
      end

      function varargout = size(sts,varargin)
          nsamp = sts.nsamp2 - sts.nsamp1 +1;
          nchan = length(sts.channels2use);
          
          out1 = nsamp;
          out2 = nchan;
          if nargin == 2
                if varargin{1} == 1
                    out1 = nsamp;
                elseif varargin{1} == 2
                    out1 = nchan;
                end
          end
          
          varargout{1} = out1;
           if nargout == 2
               varargout{2} = out2;
           end
      end
      
      function val = get(sts,varargin)
          if strcmp(varargin{1},'data') | strcmp(varargin{1},'time') 
              if nargin >= 3
                  times = varargin{2};
                  sts.nsamp1 = times(1)/sts.period;
                  sts.nsamp2 = times(2)/sts.period;
              end
              if nargin >= 4
                  sts.downsample = times(3);
              end
%               disp([sts.nsamp1 sts.nsamp2])
              sts = updateData(sts,sts.nsamp1,sts.nsamp2,sts.downSample);
              varargin = varargin(1);  % just the first flag
          end
          val = get@mytimeseries(sts,varargin{:});
      end
      
   end
end
