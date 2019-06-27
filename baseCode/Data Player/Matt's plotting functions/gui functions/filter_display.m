function handles = filter_display(handles,action)

filter_settings = inputdlg({'cut off (high pass)','order'},'Butterworth filter settings',1);

highpass = str2num(filter_settings{1});
order = str2num(filter_settings{2});

dt = mean(diff(handles.dat.Time));
samprate = 1/dt;
[b,a] = butter(order,highpass/(.5*samprate),'high');
temp = findobj(handles.axishandle,'type','line');

for ii = 1:length(temp)
    data = get(temp(ii),'YData');
    if length(data) > 2
        mn = mean(data);
        data2 = filtfilt(b,a,data);
        set(temp(ii),'YData',data2+mn);
    end
end


