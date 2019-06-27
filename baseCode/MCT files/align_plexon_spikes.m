function plexondata = align_plexon_spikes(plexondata,syncinfo)
% function plexondata = align_plexon_spikes(plexondata,syncinfo)
%     Takes onset and offset information in syncinfo and censors the spike
%     data in plexondata accordingly.  It gets rid of any spike times
%     outside the range in syncinfo and recalculates the bins and times
%     accordingly.
%

binwidth = plexondata.binneddata.binwidth;
bins = plexondata.binneddata.timebinedges - syncinfo.OnsetTime;
newbins = bins - (binwidth + rem(bins(1),binwidth));   % this should make it so there are still bins going from 0 to binwidth
newbins(end+1) = newbins(end)+binwidth;  % make sure there's one more at the end

nchannels = size(plexondata.channels,2);
neuron_n = 1;  % this counts the number of neurons, allowing for mulitple neurons for each channel
% Get cluster data
for channel = 1:nchannels
    numclusters = length(plexondata.channels(channel).clusters); %If the file is sorted, sorted units are saved from the 2nd raw downwards. If it is unsorted, units are on first raw.
    %[channel numclusters]
    if numclusters > 0
        clusters = struct();
        for ncluster = 1:1  %numclusters  % iterate through the clusters for this channel
            % shift the spike times so 0 is the onset in sync info
            sp_times = plexondata.channels(channel).clusters(ncluster).spiketimes;
            sp_times = sp_times - syncinfo.OnsetTime;
            spikehist = histc(sp_times,newbins)./binwidth; spikehist(end) = [];
            allspikes(neuron_n,:) = spikehist;  % build up the matrix with all spike rates
            allneuroninfo(neuron_n).channel = channel;  % keep track of each neuron's identify
            allneuroninfo(neuron_n).cluster = ncluster;
            neuron_n = neuron_n+1;
        end
    end
end

plexondata.aligned.spike_binneddata = allspikes;
plexondata.aligned.spike_binedges = newbins;
plexondata.aligned.spike_timeframe = newbins(2:end) - binwidth/2;
plexondata.aligned.spike_info = allneuroninfo;
