function handles = find_onsets(handles,action)

if handles.current_trace == 10
    disp('need to select a channel first')
    return
end

if ischar(action)
    settings = inputdlg({'threshold (multiple of max)','add new onsets to figure? (1/0)'},'find onsets',1,{'0.5','0'});
else
    settings{1} = num2str(action);
    settings{2} = '0';
end
    
    threshold = str2num(settings{1});
temp = get(handles.dat,'time',[1 4]);
period = mean(diff(temp));

% find the times in the display
nsamp1 = handles.viewstart*period;
nsamp2 = handles.viewstop*period;

dat = get(handles.dat,'data',[nsamp1 nsamp2]);
times = get(handles.dat,'time',[nsamp1 nsamp2]);
if handles.current_trace > size(dat,2)
    handles.current_trace = 1;
end
dat = double(dat(:,handles.current_trace));

if isa(handles.dat,'EMGTimeSeries')
    freq = 1/period;
    freq = 50;
    % highpass filter the data, then rectify
    [b,a] = butter(5,50/(freq/2),'high');
    dat = filtfilt(b,a,dat);
    
    % now low pass the rectified data
    [b,a] = butter(5,10/(freq/2),'low');
    dat3 = abs(filtfilt(b,a,abs(dat)));
    
    dat2 = tkeo_filter(dat);
    [b,a] = butter(3,50/2500);
    dat2 = filtfilt(b,a,abs(dat2));
        
    mn = median(dat3);
    sd = std(dat3);
    baseind = find(dat3 < (median(dat3) + .1*sd));
    th = mean(dat3(baseind)) + 5*std(dat3(baseind));
    th = median(dat3) + .1*sd;
    [onsets,offsets] = find_bursts(dat3,th,period);
    
    % now do it again with better cycle definitions
    nonsets = length(onsets);
    trace = dat2*0;
    for ii = 2:(nonsets-1)
        ind = (offsets(ii)+100):(onsets(ii+1)-100);
        if length(ind) < 100*1/period;
            trace(ind) = 1;
        end
    end
    baseind = find(trace);
    th = mean(dat2(baseind)) + threshold*std(dat2(baseind));
    [onsets,offsets] = find_bursts(dat2,th,period);
        
else
    mn = nanmax(dat);
    [onsets,offsets] = find_bursts(dat,threshold*mn,period);
end

newonsets = [times(onsets) times(offsets)];
if str2num(settings{2})  % they want to add the new onsets to the current ones
    current_onsets = handles.all_ided_times{handles.current_trace};
    newonsets = [newonsets; current_onsets];
end

show_ided_times(newonsets,handles.axishandle);
handles = replot_data(handles);

