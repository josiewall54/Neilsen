function handles = average_cycles(handles,action)

% finds the ided_times in the window as displayed (the current channel),
% then uses these times to find the averaged locomotor cycle.  Uses the the
% ided times only really the first one (doesn't do single referent) to go
% from onset to onset.  Assumes all cycles are consecutive here.

current_times = handles.all_ided_times{handles.current_trace};
onsets = current_times(:,1);
ncycles = length(onsets) - 1;

disp('extracting raw data')
for ii = 1:ncycles
    disp(['cycle ' num2str(ii)])
    dat{ii} = get(handles.dat,[onsets(ii) onsets(ii+1)]);
end

disp('normalizing cycles to 100bins')
nbin = 100;
allcycles = zeros(ncycles,nchan,nbin);
for ii = 1:ncycles
    [nchan,nsamp] = dat{ii};
    temp2 = zeros(nchan,nbin);
    bins = round(linspace(1,nsamp,nbin+1));
    for xx = 1:(nbin)
        temp2(:,xx) = mean(dat{ii}(:,bins(xx):bins(xx+1))');
    end
    all_cycles(ii,:,:) = temp2;
end
    