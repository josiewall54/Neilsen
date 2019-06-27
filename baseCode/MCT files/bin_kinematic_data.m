function kin_data = bin_kinematic_data(kin_data,timeframe)
% function = kin_data = bin_kinematic_data(kin_data,binsize,timeframe)
%   This function resamples the kinematic data in kin_data according to the
%   times specified in timeframe.

binsize = mean(diff(timeframe));
freq = mean(diff(kin_data.timeframe));
nsampPerBin = binsize*(1/freq);  % this is the number of samples in each bin
nsamp = length(kin_data.x);
% timeframe = kin_data.timeframe(1):binsize:kin_data.timeframe(end);  % these are the times for the binned data  
timeframe_cent = timeframe(2:end) - binsize;

% winSize = LFPwindowSize; 
% % viconFreq = 200;
% 
% viconSampsPerBin = binSize*viconFreq;
% epiKinRatio = an_data.freq(1)/viconFreq;
% excludeSamps = round(winSize/epiKinRatio - viconSampsPerBin);
% 
% an_data.rawKinematicData.rawKinematics(1:excludeSamps,:) = [];
% an_data.rawKinematicData.(refMarkerField)(1:excludeSamps,:) = [];
% an_data.rawKinematicData.kinTimeframe = [ 0: 1/viconFreq : size(an_data.rawKinematicData.rawKinematics,1)* (1/viconFreq) - (1/viconFreq) ]';
% 
% BINNING: Vq = interp1(X,V,Xq) interpolates to find Vq, the values of the
% underlying function V = F(X) at the query points Xq. 


raw_kin = interp1(kin_data.timeframe, kin_data.rawKinMatrix(:,1:end), timeframe_cent,'linear','extrap');
ref_kin = interp1(kin_data.timeframe, kin_data.refKinMatrix(:,1:end), timeframe_cent,'linear','extrap');

%Interpolate NaNs. Create a vector to tell which marker is worth decoding.
%If it has too many NaNs, discard.
interpolatedKin = []; interpolatedKin_ref = [];
for i = 1:size(raw_kin,2)
    interpolatedKin = [interpolatedKin inpaint_nans(raw_kin(:,i))];
    interpolatedKin_ref = [interpolatedKin_ref inpaint_nans(ref_kin(:,i))];
end
kin_data.BinnedRawKinMatrix = interpolatedKin;
kin_data.BinnedRefKinMatrix = interpolatedKin_ref;
kin_data.Binnedtimeframe = timeframe(2:end);