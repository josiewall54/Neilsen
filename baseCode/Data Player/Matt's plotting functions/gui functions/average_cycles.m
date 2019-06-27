function handles = average_cycles(handles,action)

% finds the ided_times in the window as displayed (the current channel),
% then uses these times to find the averaged locomotor cycle.  Uses the the
% ided times only really the first one (doesn't do single referent) to go
% from onset to onset.  Assumes all cycles are consecutive here.

current_times = handles.all_ided_times{handles.current_trace};
if isempty(current_times)
    disp('no ided times')
    return
end
onsets = current_times(:,1);

% function [raw_cycles, standard_cycles] = get_cycle_data(sts,onsets)

ncycles = length(onsets) - 1;

settings = inputdlg({'number of bins'},'Averaging locomotor cycles',1);
nbin = str2num(settings{1});

freq = 1/handles.dat.period;
% freq = 5000;
[b,a] = butter(5,50/(freq/2),'high');
disp('extracting raw data')
for ii = 1:ncycles
%  disp(['cycle ' num2str(ii) ' ' num2str(onsets(ii+1) - onsets(ii))])
    temp = (get(handles.dat,'data',[onsets(ii) onsets(ii+1)]));
    dat{ii} = abs(filtfilt(b,a,temp));
end

ncycles = length(dat);
[nsamp,nchan] = size(dat{1});

disp(['normalizing cycles to ' num2str(nbin) ' bins'])

all_cycles = normalize_cycles(dat,nbin);

% [nsamp,nchan] = size(dat{1});
% for ii = 1:ncycles
%    allnsamp(ii) = length(dat{ii});
% end
% avg_nsamp = min(allnsamp);
% 
% all_cycles = zeros(ncycles,nchan,nbin);
% nused = 0;
% for ii = 1:ncycles
%     [nsamp,nchan] = size(dat{ii});
%     if nsamp < 2*avg_nsamp        
%         nused = nused+1;
%         temp2 = zeros(nbin,nchan);
%         bins = round(linspace(1,nsamp,nbin+1));
%         for xx = 1:(nbin)
%             temp2(xx,:) = sum(dat{ii}(bins(xx):bins(xx+1),:));
%         end
%         all_cycles(nused,:,:) = temp2;
%     else
%         disp(['skipping cycle ' num2str(ii) ' times: ' num2str([onsets(ii) onsets(ii+1)])])
%     end           
% end
% 

avg_cycle = squeeze(mean(all_cycles,1));
for ii = 1:nchan
     norm_cycle2(:,ii) = (avg_cycle(:,ii) - min(avg_cycle(:,ii)))/max(avg_cycle(:,ii));
     norm_cycle(:,ii) = handles.ygain(ii)*avg_cycle(:,ii);
end


figure
subplot(1,2,1)
plot_matrix(norm_cycle2/2,1:nbin)

disp('created all_cycles in the base workspace')
assignin('base','all_cycles',all_cycles)
assignin('base','raw_cycles',dat)
% assignin('base','avg_cycle',avg_cycle)

