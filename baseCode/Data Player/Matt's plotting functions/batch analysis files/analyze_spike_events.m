function handles = analyze_spike_events(handles,action)
% Function to extract events as determined by the threshold set by the
% user.  Opens the GUI for spikefig, which can then be used to extract
% parameters that can be used for clustering.
%

answers = inputdlg({'Extract data from Window(W) or Whole file(F)?',...
                   'Number of samples to extract before event',...
                   'Number of samples to extract after event'},...
                    'Analyze spike events',[1 1 1],...
                    {'W','20','40'});

if ~strcmp(answers{1},'W')
    disp('sorry, only able to extract events for the window currently')
end

pre_samp = str2num(answers{2});
post_samp = str2num(answers{3});

if handles.current_trace == max(handles.yoffset+.5)+1; % there isn't a trace currently selected
    disp('need to select a trace first')
    return
end
index = handles.current_trace;  % the currently selected trace index
samples = get_view();
handles.dat.nsamp1 = samples(1);
handles.dat.nsamp2 = samples(2);
handles.dat = updateData(handles.dat);
            
data = handles.dat.Data;  % the data for the period
%             times = ets.Time;  % the times for the period
spt = sp_times(data(:,index),handles.real_threshold(index)); % find the spike events in the scaled data
aps = sp_extract(data(:,index),spt,pre_samp,post_samp);  % arbitrary windows to use
open('spfig_new.fig')
spikefig('data',aps',(spt+samples(1))*handles.dat.period*1000);

