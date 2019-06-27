% batch file to process all the animals in an analysis at once
% takes an Excel spreadsheet which lists the results files, the allanswers
% file, and the directory where the data is located.
% Goes through and reads in each results file and allanswers file,
% calculates the ratio response according to the parameters set here, then
% saves it in a common Excel spreadsheet as listed here.
%

%%  Configures how the analysis will run
opts.pre_pulse_window = .5;  % the amount of time (in seconds) to extract before the pulse
opts.post_pulse_window = 2;  % the amount of time (in seconds) to extract after the pulse
opts.samplerate = 10000;
opts.baseline = [1 4000]; % the sample number where the stim occured - leave a margin to deal with filtering issues
opts.response = [6000 25000];  % number of samples after stim before starting calculations
opts.include_flags = {'Y'};
opts.filter = 1;
opts.stimfiles = 0;


%%

source_XLS_file = 'All_experiments.xlsx';
output_XLS_file = 'test results.xlsx';
currdir = pwd;

[num,txt,raw] = xlsread(source_XLS_file);  % the xls spreadsheet that describes the files to use

Header = raw(1,:);   % the headings in the XLS spreadsheet
Entry = raw(2:end,:);   % the entries after the first row contain the information

% find the key columns, based on the header
Dir_column = find(strcmp(Header,'Directory'));
Results_column = find(strcmp(Header,'Results file'));
Answers_column = find(strcmp(Header,'Allanswers file'));
Channel_column = find(strcmp(Header,'Channel'));
n_total_columns = length(Header);  % the total Number of columns
non_critical_columns = setdiff(1:n_total_columns,[Dir_column Results_column Answers_column]);
n_noncrit_columns = length(non_critical_columns);  % these are the non-key columns

nanimals = size(Entry,1);
ncols = size(Entry,2);
% initialize the New_Entry variable with the headers
New_Entry = cell(1,5);  % initialize New_Entry
New_Entry(1,1:5) = {'Directory','Results file','Answers file','File ID','Channel #'};
n_entry = 2;  % this is where the new entries start from

for ii = 1:nanimals  % iterate over the number of animals
    disp(['animal #' num2str(ii)])
    directory = Entry{ii,Dir_column};   % pull out the data for this animal from the spreadsheet info
    results_file = Entry{ii,Results_column};
    answers_file = Entry{ii,Answers_column};
    
    cd(directory)  % move to the directory
    temp = load(results_file);  % read the results file
    results = temp.results;  % pull out the variables
    allnotes = temp.allnotes;
    stimtimes = temp.stimtimes; 
    if isfield(temp,'newopts')
        newopts = temp.newopts;
        opts.samplerate = newopts.samplerate;  % if newopts is there, use its sample rate
    end
        
    temp = load(answers_file);  % read in the all_answers file
    field = fieldnames(temp);
    allanswers = temp.(field{1});  % assuming that this variable is there
    
    nfiles = length(results);  % the number of files in the results variable
    nmusc = size(results{1},1);  % the number of channels
    maxntrials = size(allanswers,2);  % the maximum number of trials
    intresp = zeros(nmusc,nfiles,maxntrials);  % initialize the integrated response for each trial
    [b,a] = butter(5,50/(.5*opts.samplerate),'high');  % this creates the filter to be used
    for mm = 1:nmusc  % loop over the number of channels
        for kk = 1:nfiles  % loop over the number of files
            ntrials = size(results{kk},2);  % find the number of trials in the current file
            for jj = 1:ntrials  % loop over the number of trials
                if sum(strcmp(allanswers{kk,jj},opts.include_flags))  % anything other then Y means blank out the trial                                 
                    temp = squeeze(results{kk}(mm,jj,:));  % get the trial
                    if opts.filter  % for sacral prep filtering
                        temp = filtfilt(b,a,temp);  % get rid of the DC shifts by highpass filtering
                    end
                    % find the integrated response and the number of events above threshold
                    [ratio, total] = calc_integrated_response(abs(temp),opts.baseline,opts.response);
                    intresp(mm,kk,jj) = ratio;
                else  % if the trial is to be excluded, set it to NaN
                    intresp(mm,kk,jj) = NaN;
                end
            end
        end
    end
    intresp(intresp == 0) = NaN;  %  any of the integrated responses that haven't been assigned, set them to NaN to flag them

    if ~isempty(Channel_column)  % if they only want a single channel, then collapse intresp
        channel = (Entry{ii,Channel_column});
        intresp = intresp(channel,:,:);  % get rid of everything but that channel
    end

    % ok, now assemble these results into a spreadsheet table
    for jj = 1:size(intresp,1)  % iterate over the number of channels
        for kk = 1:nfiles  % iterate over the number of files
            New_Entry{n_entry,1} = directory;   % recopy the information into the New_Entry
            New_Entry{n_entry,2} = results_file;
            New_Entry{n_entry,3} = answers_file;
            if opts.stimfiles
                New_Entry{n_entry,4} = allnotes{kk};  % if it's stim, then the file name is in allnotes
            else
                New_Entry{n_entry,4} = ['File # ' num2str(kk)];  % otherwise, just write the file number
            end                
            New_Entry{n_entry,5} = ['Channel ' num2str(jj)];
            New_Entry(n_entry,6:(6+n_noncrit_columns-1)) = Entry(ii,non_critical_columns);
            start =  6+n_noncrit_columns;
            stop = start + maxntrials;
            for mm = 1:maxntrials  % copy the trial information into the new entries
                New_Entry{n_entry,start+mm} = squeeze(intresp(jj,kk,mm));  % all the trials for this file
            end
            n_entry = n_entry+1;
        end  % number of files
    end  % number of channels
end  % animal

cd(currdir)
xlswrite(output_XLS_file,New_Entry);
