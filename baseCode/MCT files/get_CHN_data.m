function [outdata, outtimes] = get_CHN_data(indata, flag, varargin)

if nargin == 3
    req_times = varargin{1};
    if length(req_times > 2)
        req_times = [req_times(1) req_times(end)];
    end
else
    req_times = [-Inf Inf];
end

% figure out what type of data structure they've sent in, and get the
% requested data
switch indata.datatype
    case 'emg'
        [outdata,outtimes] = get_CHN_emg_data(indata,flag);
    case 'field'
        [outdata,outtimes] = get_CHN_field_data(indata,flag);
    case 'spike'
        [outdata,outtimes] = get_CHN_spike_data(indata,flag);
    case 'kinematic'
        [outdata,outtimes] = get_CHN_kinematic_data(indata,flag);
    otherwise
        disp('unknown data type')
end

% now pick out the specific times of the data
ind = find((outtimes >= req_times(1)) & (outtimes <= req_times(2)));
outdata = outdata(ind,:);
outtimes = outtimes(ind);

% this is a hack to deal with the fielddata, since it's times are offset
% from the others
% if strcmp(indata.datatype,'field')
%     disp('small time shift for field data here')
%     outtimes = outtimes - outtimes(1);
% end

end


function [outdata,outtimes] = get_CHN_emg_data(indata,flag)

switch flag
    case 'raw'
        outdata = indata.data;
        outtimes = indata.timeframe;        
    case 'binned'
        outdata = indata.binned.data;
        outtimes = indata.binned.timeframe;
    otherwise
        disp('unknown flag')
end

end

function [outdata,outtimes] = get_CHN_field_data(indata,flag)

switch flag
    case 'raw'
        outdata = indata.data';
        outtimes = indata.timeframe;
    case {'binned CAR','binned'}
        outdata = indata.binnedEpiduralData.CAR3';
        outtimes = indata.binnedEpiduralData.timeframe;
    case 'binned raw'
        outdata = indata.binnedEpiduralData.rawEpidural';
        outtimes = indata.binnedEpiduralData.timeframe;
    otherwise
        disp('unknown flag')
end

end

function [outdata,outtimes] = get_CHN_spike_data(indata,flag)

switch flag
    case 'raw'
        disp('no support for raw data request for spikedata')        
    case 'binned'
        outdata = indata.aligned.spike_binneddata';
        outtimes = indata.aligned.spike_timeframe;
    otherwise
        disp('unknown flag')
end

end

function [outdata,outtimes] = get_CHN_kinematic_data(indata,flag)

switch flag
    case 'raw'
        outdata = indata.rawKinMatrix;
        outtimes = indata.timeframe;
    case 'binned'
        outdata = indata.BinnedRefKinMatrix;
        outtimes = indata.Binnedtimeframe;
    otherwise
        disp('unknown flag')
end

end


