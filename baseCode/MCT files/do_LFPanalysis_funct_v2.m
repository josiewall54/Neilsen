
function LFP_struct = do_LFPanalysis_funct_v2(LFP_struct, params, varargin)

% Epidural Analysis

% Write here a description of what we are doing. 
% CAR, bandpass, power spectrum etc. 
% Explain the data we are creating to decode from

%% Input vararg: set defaults

channels = params.data_ch;
binSize = params.binSize;
LFPwindowSize = params.LFPwindowSize;

%% LFP Data Processing

% Take only the channels that contain epidural data:
[channels, ~] = ismember(LFP_struct.channel, channels);
epiduralData = LFP_struct.data(channels,:);


% notch filter at 60Hz
Fs = LFP_struct.freq(1);
df = designfilt('bandstopiir','PassbandFrequency1',55,...
               'StopbandFrequency1',58,'StopbandFrequency2',62,...
               'PassbandFrequency2',65,'PassbandRipple1',1,...
               'StopbandAttenuation',60,'PassbandRipple2',1,...
               'SampleRate',Fs,'DesignMethod','ellip');           
% epiduralData = filtfilt(df,epiduralData')';
% LFP_struct.data(channels,:) = epiduralData;

% Common Average Referencing (CAR) is done to reduce common artifact.
% CAR type 1 : each channel referenced with respect to all channels (including oneself)
% CAR type 2 : each channel referenced with respect to remaining channels (excluding oneself)
LFP_struct.rawEpiduralData = do_CAR(epiduralData);
LFP_struct.rawEpiduralData.rawEpidural = epiduralData;

% Perform the LFP analysis, calculating the power spectrum of the LFPs at
% target frequency bands, binning the data at the same time.
LFP_struct.binnedEpiduralData = do_SpatialFiltering(LFP_struct, params);

%Add time frame for binned data
% LFP_struct.timeframe = [ 0 : binSize : length(LFP_struct.binnedEpiduralData.rawEpidural)*binSize - binSize]';

% this updates the timing of the bins.  because the LFP requires nFFT
% samples before it can generate any values, the first bin returned by this
% analysis is actually at a different time. The first bin corresponds to
% the power in samples 1:nFFT.  We have a sliding window of NsampPerBin
% samples.  So the first bin corresponds to the time of the final
% NSampPerBin of the nFFT window.  The code below does this

% need to update this so that the bin times line up to be integer multiples
% of the binsize - i.e. so there's a bin in there that goes from 0 to
% binsize.  This will allow me to line up the times ok with the other data
% streams.

NsampPerBin = binSize*LFP_struct.freq(1);
indices = (LFPwindowSize - NsampPerBin + 1):LFPwindowSize;  % these are the indices of the first bin, constraining this causality
% this next line finds the indices for the center of each window, starting
% with the index for the center of the first bin, then advancing by NsampPerBin samples
temp = mean(indices) + 1:NsampPerBin:(length(LFP_struct.binnedEpiduralData.rawEpidural)*NsampPerBin) - 1;
% now with those indices, this next line finds the corresponding times,
% taken from the original time frame
timeframe2 = interp1(1:length(LFP_struct.timeframe),double(LFP_struct.timeframe),double(temp));
LFP_struct.binnedEpiduralData.timeframe = timeframe2;   % these are the times for each of the values returned by this power analysis


% newbins = bins - (binwidth + rem(bins(1),binwidth));   % this should make it so there are still bins going from 0 to binwidth
% newbins(end+1) = newbins(end)+binwidth;

end