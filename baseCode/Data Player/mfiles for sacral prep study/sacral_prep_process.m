%%

conditions = {'recruitment', 'StrychBaseline','sb'};  % the file names to process
% conditions = {'predrug'};  % the file names to process
conditions = {'strych_'};  % the file names to process



predur = .5;  % the time before the stim to extract
postdur = 2;    % the time after the stim to extract

for cond = 1:length(conditions)
    disp(['condition ' conditions{cond}])
    allfnames = dir([conditions{cond} '*.mat']);  % find the files for this condition
    nfiles = length(allfnames);
       
    for filen = 1:nfiles
        fname = allfnames(filen).name;   % go through each of the files for this condition
%         rootname = strtok(fname,'_');
        rootname = conditions{1}(1:(end-1));
        
        timesvar = [rootname '_Ch2*'];  % the variable with the stimulation
        notevar = [rootname '_Ch30'];   % the variable with the comments
        
        datavarnames = {[rootname '_Ch10'],[rootname '_Ch11'],[rootname '_Ch12'],[rootname '_Ch13']};  % the variables with the channel data
        
        ndatavar = length(datavarnames);
        
        temp = load(fname,timesvar);  % try to read in the stim times variable
        if isempty(fieldnames(temp))  % if it's empty, make a dummy
            times_data = [];
            nstim = 0;
            times = [];
        else    % otherwise, read off the values you care about
            fields = fieldnames(temp);
            times_data = temp.(fields{1});
            times = times_data.times;
            dtimes = diff(times);
            ind = find(dtimes > 1);
            times = times(ind);  % get rid of any pulses within trains            
            nstim = length(times);
        end
        temp = load(fname,notevar);  % do the same thing for the notes
        if isempty(fieldnames(temp))
            notes_data = [];
        else
            notes_data = temp.(notevar);
        end
        
        for ii = 1:ndatavar   % go over each of the variables
            disp(['reading ' fname ' ' datavarnames{ii}]);
            temp = load(fname,datavarnames{ii});  % load in the data variable
            data = temp.(datavarnames{ii}); 
            for jj = 1:nstim  % go over each of the stimulation pulses
                sampn = round(1/data.interval*(times(jj)));  % this is the sample number for the pulse
                n1 = round(sampn - predur*1/data.interval);  % the starting sample
                n1 = max(1,n1);   % make sure it's not before the start of the trial
                n2 = round(sampn + postdur*1/data.interval);  % the stopping sample
                n2 = min(n2,data.length);  % make sure it's not after the end of the trial
                allresp(ii,jj,1:(n2-n1+1)) = data.values(n1:n2);  % collect the data
            end
        end
        if nstim == 0
            allresp = [];
        end
        results{filen} = allresp;  % collect all the responses for this condition
        stimtimes{filen} = times;
        allnotes{filen} = notes_data;
        clear allresp
    end
    outfile = ['results_' conditions{cond} '_results'];
    disp(['saving ' outfile]); 
    save(outfile,'results','allnotes','stimtimes')  % save all the responses and notes for this condition
    clear results
    clear allnotes
    clear stimtimes
end

