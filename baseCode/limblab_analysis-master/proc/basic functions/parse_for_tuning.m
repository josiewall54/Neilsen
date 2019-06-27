function [outstruct]=parse_for_tuning(bdf,method,varargin)
    %gets a structure of arm data and a matrix of firing rate data 
    % function call is of the form:
    %[outstruct]=parse_for_tuning(bdf,method)
    %the bdf must be a standard bdf extended with the following fields:
    %   -bdf.units.FR, containing a 2 column matrix containing timestamps
    %       and associated firing rate or bin counts
    %   -bdf.TT, containg the trial table
    %   -bdf.TT_hdr, containg a header structure for the trial table
    %       The header must contain the following fields:
    %           start_time
    %           end_time
    %           go_cue
    %       Depending on the parsing method selected the following 
    %       additional fields MAY be required:
    %           bump_time
    %           bump_hold
    %           bump_ramp
    %
    %the method input must be a string defining what parsing method will be
    %used. The following are viable method strings:
    %   -'continuous'
    %   -'peak speed'
    %   -'peak force'
    %   -'peak dfdt'
    %   -'peak acceleration'
    %   -'peak dfdtdt'
    %   -'target onset'
    %   -'go cues'
    %   -'trials'
    %   -'bumps'
    %
    %Details of the function operation may be specified using key-value 
    %pairs as follows:
    %[outstruct]=parse_for_tuning(bdf,method,key,value...)
    % valid key-value pairs are:
    %   -('opts',options_struct), in this case the structure will contain 
    %   options detailing how parse_for_tuning will implement the selected 
    %   method. Options not included in the options struct will be set to 
    %   default values, typically 0.
    %   -('use_FR', use_FR), a flag to indicate whether to to use firing 
    %   rate data. If use_FR==true, parse_for_tuning will look for
    %   bdf.units.FR fields. This parameter defaults to true
    %   -('units',which_units), where which_units is a vector of integers
    %   specifying which units to generate FR series for
    %   -('use_LFP',use_LFP), flag indicating whether to use LFP data for
    %   tuning. if use_LFP==true, parse_for_tuning will look for a bdf.LFP 
    %   structure. The LFP structure should be in the format generated by 
    %   the getLFPpsd function. this parameter defaults to false
    %   -('chans',which_chans), where which_chans is a vector of integers
    %   specifying which channels to take LFP data from. ignored unless
    %   use_LFP==true
    %   -('bands',which_bands), where which_bands is a list of integers
    %   specifying the columns of the LFP data to use. ignored unless
    %   use_LFP==true
    
    %Details of the options struct:
    %options struct may contain the following fields:
    %   -lags: a vector containing the specific lags in ms to compute 
    %       kinetics for. positive lags indicate kinetic data preceding the
    %       current point, negative lags indicate kinetic data following the
    %       current point. default is 0
    %   -compute_pos_pds: flag that will be passed to the output struct.
    %       default is 0 (false)
    %   -compute_vel_pds: flag that will be passed to the output struct
    %       default is 1 (true)
    %   -compute_acc_pds: flag that will be passed to the output struct
    %       default is 0 (false)
    %   -compute_force_pds: flag that will be passed to the output struct
    %       default is 0 (false)
    %   -compute_dfdt_pds: flag that will be passed to the output struct
    %       default is 0 (false)
    %   -compute_dfdtdt_pds: flag that will be passed to the output struct
    %       default is 0 (false)
    %   -compute_EMG_pds: flag that will be passed to the output struct
    %       default is 0 (false)
    %   -data_offset: offset in ms between kinetic and Firing rate data. Used to
    %       account for transmission latency. negative offset for FR data after
    %       kinetic data (sensory), positive offset for FR leading kinetic
    %       data (motor). default is 0
    %   -data_window: time in ms to include in output struct. used for
    %       methods that sample the mean kinematics and FR around some point of
    %       interest, such as target onset or peak velocity. default is
    %       100ms
    
    
    %the output structure outstruct has the following fields:
    %   -armdata, which is a struct array formatted for the calculate tuning
    %       function. 
    %   -FR, which is a matrix of firing rates for each unit
    %   -unitlist, which is the ordered list of units in the FR matrix
    %outstruct.armdata has cells each containing a structure with the 
    %following fields:
    %   -data, a column matrix of data points, each row corresponding to an
    %   observation
    %   -name, a string defining the type of data e.g. 'pos', 'vel',
    %   'force' 'EMG'
    %   -num_lags, an integer specifying the number of lags included in the
    %   data field. 
    %   -num_base_col, an integer telling how many data columns there are
    %   before including additional lags
    %   
    
    %written by Tucker Tomlinson Jan-8-2015
    
    %% sanity check BDF:
        if ~isfield(bdf,'TT') 
            if ~strcmp(method,'continuous')
                error('parse_for_tuning:NoTrialTableField','The BDF does not have the bdf.TT field containing the trial table')
            else
                warning('parse_for_tuning:NoTrialTableField','The BDF does not have the bdf.TT field containing the trial table')
            end
        end
        if ~isfield(bdf,'TT_hdr')
            if ~strcmp(method,'continuous')
                error('parse_for_tuning:NoTrialTableHeaderField','The BDF does not have the bdf.TT_hdr field containing the trial table header')
            else
                warning('parse_for_tuning:NoTrialTableHeaderField','The BDF does not have the bdf.TT_hdr field containing the trial table header')
            end
        end
        if ~isfield(bdf.units,'FR')
            error('parse_for_tuning:NoFiringRateField','The BDF does not have the bdf.units.FR field containing the firing rate')
        end
        
    %% set up optional inputs to the function
    method_opts=[];
    which_units=[];
    use_FR=true;
    use_LFP=false;
    which_chans=[];
    which_bands=[];
    only_good_data=0;
    for i=1:2:length(varargin)
        switch varargin{i}
            case 'opts'
                method_opts=varargin{i+1};
            case 'units'
                which_units=varargin{i+1};
            case 'use_FR'
                use_FR=varargin{i+1};
            case 'use_LFP'
                use_LFP=varargin{i+1};
            case 'chans'
                which_chans=varargin{i+1};
            case 'bands'
                which_bands=varargin{i+1};
            case 'only_good_data'
                only_good_data=1;
            otherwise
                error('Parse_for_tuning:UnrecognizedFlag',strcat('The ',num2str(i+2),'input is not a valid input'))
        end
    end
    if isempty(which_units)
        for i = 1:size(bdf.units, 2);
            if size(bdf.units(i).ts, 1) > 0 & bdf.units(i).id(1,2)~=255
                which_units = [which_units; i];
            end
        end
    end
    %% set generic kinetic variables from the bdf 
    pos=bdf.pos;
    if isfield(bdf,'vel')
        vel=bdf.vel;
    else
        [grad_rows,grad_cols]=gradient(bdf.pos(:,2:end),[1:size(bdf.pos,2)-1],bdf.pos(:,1));
        vel=[bdf.pos(:,1),grad_cols];
    end 
    if isfield(bdf,'acc')
        acc=bdf.acc;
    else
        [grad_rows,grad_cols]=gradient(vel(:,2:end),[1:size(vel,2)-1],vel(:,1));
        acc=[bdf.pos(:,1),grad_cols];
    end
    if isfield(bdf,'force')
        if isfield(bdf.force,'labels')
            force=bdf.force.data;
        else
            force=bdf.force;
        end
        if isfield(bdf,'dfdt')
            dfdt=bdf.dfdt;
        else
            [grad_rows,grad_cols]=gradient(force(:,2:end),[1:size(force,2)-1],force(:,1));
            dfdt=[force(:,1), grad_cols];
        end
        if isfield(bdf,'dfdtdt')
            dfdtdt=bdf.dfdtdt;
        else
            [grad_rows,grad_cols]=gradient(dfdt(:,2:end),[1:size(dfdt,2)-1],force(:,1));
            dfdtdt=[force(:,1), grad_cols];
        end
    else
        force=[pos(:,1),zeros(size(pos(:,2:end)))];
        dfdt=force;
        dfdtdt=force;
    end
    if isfield(bdf,'emg')
        EMG=bdf.emg.data;
    else
        EMG=[pos(:,1),zeros(size(pos(:,2:end)))];
    end
    if only_good_data
        good_data=bdf.good_kin_data;
    else
        good_data=ones(size(bdf.pos(:,1)));
    end
    %% set the list of channel/unit IDs for the selected units:
    if use_FR
        unit_ids=-1*ones(length(which_units),2);
        for i=1:length(which_units)
            unit_ids(i,:)=bdf.units(which_units(i)).id;
        end
    else
        unit_ids=[];
    end
    if use_LFP
        LFP_ids=-1*ones(length(which_chans)*length(which_bands),2);
        which_bands=reshape(which_bands,length(which_bands),1);
        for i=1:length(which_chans)
            LFP_ids(1+(i-1)*length(which_bands):1+(i)*length(which_bands))=[which_chans(i)*ones(length(which_bands),1),which_bands];
        end
    else
        LFP_ids=[];
    end
    %% do generic processing common to all methods:
        %compute data for lags
            pos_lag_data=[];
            vel_lag_data=[];
            acc_lag_data=[];
            force_lag_data=[];
            dfdt_lag_data=[];
            dfdtdt_lag_data=[];
            EMG_lag_data=[];
            if isfield(method_opts,'lags')
                num_lags=length(method_opts.lags);
                lags=method_opts.lags;
                if(max(lags)>5)
                    warning('Parse_For_Tuning:LargeLag','At least one of the lags is graeter than 5s. The parse_for_tuning function expects lags in s, and the input may specify the lags in ms.')
                end
            else
                num_lags=0;
                lags=[];
            end
            if num_lags>0
                %preallocate matrices for shifted lag data
                pos_lag_data=zeros(size(pos,1),(size(pos,2)-1)*num_lags);
                vel_lag_data=zeros(size(vel,1),(size(vel,2)-1)*num_lags);
                acc_lag_data=zeros(size(acc,1),(size(acc,2)-1)*num_lags);
                force_lag_data=zeros(size(force,1),(size(force,2)-1)*num_lags);
                dfdt_lag_data=zeros(size(dfdt,1),(size(dfdt,2)-1)*num_lags);
                dfdtdt_lag_data=zeros(size(dfdtdt,1),(size(dfdtdt,2)-1)*num_lags);
                EMG_lag_data=zeros(size(EMG,1),(size(EMG,2)-1)*num_lags);
                for i=1:length(method_opts.lags)
                    tmp=bdf.pos(:,1)-method_opts.lags(i);
                    pos_lag_data(:,(1+(i-1)*(size(pos,2)-1)):(i*(size(pos,2)-1)))=interp1(pos(:,1),pos(:,2:end),tmp);
                    vel_lag_data(:,(1+(i-1)*(size(vel,2)-1)):(i*(size(vel,2)-1)))=interp1(vel(:,1),vel(:,2:end),tmp);
                    acc_lag_data(:,(1+(i-1)*(size(acc,2)-1)):(i*(size(acc,2)-1)))=interp1(acc(:,1),acc(:,2:end),tmp);
                    force_lag_data(:,(1+(i-1)*(size(force,2)-1)):(i*(size(force,2)-1)))=interp1(force(:,1),force(:,2:end),tmp);
                    dfdt_lag_data(:,(1+(i-1)*(size(dfdt,2)-1)):(i*(size(dfdt,2)-1)))=interp1(dfdt(:,1),dfdt(:,2:end),tmp);
                    dfdtdt_lag_data(:,(1+(i-1)*(size(dfdtdt,2)-1)):(i*(size(dfdtdt,2)-1)))=interp1(dfdtdt(:,1),dfdtdt(:,2:end),tmp);
                    EMG_lag_data(:,(1+(i-1)*(size(EMG,2)-1)):(i*(size(EMG,2)-1)))=interp1(EMG(:,1),EMG(:,2:end),tmp);
                end
            end
        % set up offset and window
            if isfield(method_opts,'data_offset')
                data_offset=method_opts.data_offset;
                if(data_offset>5)
                    warning('Parse_For_Tuning:LargeOffset','The data offset is graeter than 5s. The parse_for_tuning function expects the offset in s, and the input may specify the offset in ms.')
                end
            else
                data_offset=0;
            end
            if isfield(method_opts,'data_window')
                data_window=method_opts.data_window;
                if(data_window>5)
                    warning('Parse_For_Tuning:LargeWindow','The data window is greater than 5s. The parse_for_tuning function expects the window in s, and the input may specify the window in ms.')
                end
            else
                data_window=.100;
            end
            
        % get firing rate timeseries to use in parsing kinematic data
        if use_FR 
            timeseries=bdf.units(which_units(1)).FR(:,1);
            %check to see that we have the same timeseries
            if use_LFP & ~isempty(find((bdf.LFP.t-timeseries),1))
                warning('parse_for_tuning:differentLFPandFRtimes','the LFP data and FR data use different timeseries. LFP data will be interpolated to the FR timeseries before parsing')
            end
        elseif use_LFP
            timeseries=bdf.LFP.t;
        else
            error('parse_for_tuning:noNeuralDataSpecified','the user has specified not to use FR or LFP data, so there is no neural data to parse')
        end
     
        % get sequence of target onsets, trial starts, and trial ends,
        % go-cues etc
        if ~strcmp(method,'continuous')
            trial_starts=bdf.TT(:,bdf.TT_hdr.start_time);
            trial_ends=bdf.TT(:,bdf.TT_hdr.end_time);
            switch bdf.meta.task
                case 'RW'
                    targets_per_trial=bdf.TT(:,2);
                    target_onsets=bdf.TT(:,7+targets_per_trial:7+2*targets_per_trial-1);
                    target_onsets=reshape(target_onsets',(size(target_onsets,1)*size(target_onsets,2)),1);%make it a column vector
                    mask=target_onsets>1;%exclude reaches that weren't done (time is -1 in trial table)
                    target_onsets=target_onsets(mask);
                    
                    trial_times=[trial_starts,trial_ends];
                    trial_times=trial_times(bdf.TT(:,bdf.TT_hdr.trial_result)==0,:); % only successful trials

                    go_cues=target_onsets;
                    bump_times=[];
                case 'RW_chaotic'
                    targets_per_trial=bdf.TT(:,2);
                    target_onsets=bdf.TT(:,7+targets_per_trial:7+2*targets_per_trial-1);
                    target_onsets=reshape(target_onsets',(size(target_onsets,1)*size(target_onsets,2)),1);%make it a column vector
                    mask=target_onsets>1;%exclude reaches that weren't done (time is -1 in trial table)
                    target_onsets=target_onsets(mask);

                    trial_times=[trial_starts,trial_ends];
                    go_cues=target_onsets;
                    bump_times=[];
                case 'CO'
                    target_onsets=bdf.TT(:,bdf.TT_hdr.ot_time);
                    go_cues=bdf.TT(:,bdf.TT_hdr.go_cue);
                    
                    trial_times=[trial_starts,trial_ends];
                    
                    %find successful movement times
                    move_trials = bdf.TT(:,bdf.TT_hdr.go_cue)~=-1 & bdf.TT(:,bdf.TT_hdr.trial_result)==uint8('R');
                    move_times = [go_cues(move_trials) trial_ends(move_trials)];
                    
                    %find bump times
                    bump_times=[bdf.TT(:,bdf.TT_hdr.bump_time) trial_ends];
                    bump_times(bump_times(:,1)==-1,:) = [];
                    
                    %clean up target onsets and go cues
                    go_cues(go_cues==-1) = [];
                    target_onsets(target_onsets==-1) = [];
                case 'BC'
                    go_cues=bdf.TT(:,bdf.TT_hdr.go_cue);
                    trial_times=[trial_starts,trial_ends];
                    target_onsets=go_cues;
                    target_onsets(find(bdf.TT(:,bdf.TT_hdr.targets_during_bump)))=trial_starts(find(bdf.TT(:,bdf.TT_hdr.targets_during_bump)));
                    
                    %find successful movement times
                    move_trials = bdf.TT(:,bdf.TT_hdr.go_cue)~=-1 & bdf.TT(:,bdf.TT_hdr.trial_result)==uint8('R');
                    move_times = [go_cues(move_trials) trial_ends(move_trials)];
                    
                    %find bump times
                    bump_times=[bdf.TT(:,bdf.TT_hdr.bump_time) trial_ends];
                    bump_times(bump_times(:,1)==-1,:) = [];
                    
                    %clean up target onsets and go cues
                    go_cues(go_cues==-1) = [];
                    target_onsets(target_onsets==-1) = [];
                    %assumes psychometric bump choice task, not boubker's
                    %detection task
                case 'CO_bump'
                    trial_times=[trial_starts,trial_ends];
                    target_onsets=bdf.TT(:,bdf.TT_hdr.start_time);
                    go_cues=bdf.TT(:,bdf.TT_hdr.go_cue);
                    bump_times=[bdf.TT(:,bdf.TT_hdr.bump_time)+bdf.TT(:,bdf.TT_hdr.bump_delay) bump_times+bdf.TT(:,bdf.TT_hdr.bump_dur)+2*+bdf.TT(:,bdf.TT_hdr.bump_ramp)];
                case 'isometric'
                    trial_times=[trial_starts,trial_ends];
                    target_onsets=bdf.TT(:,bdf.TT_hdr.start_time);
                    go_cues=bdf.TT(:,bdf.TT_hdr.go_cue);
                    bump_times=[];
                case 'WF'
                    trial_times=[trial_starts,trial_ends];
                    target_onsets=bdf.TT(:,bdf.TT_hdr.start_time);
                    go_cues=bdf.TT(:,bdf.TT_hdr.go_cue);
                    bump_times=[];
            end
        end
    %% perform method specific selection of times of interest
        switch method
            case 'continuous'
                %viable method_opts for the continuous method:
                %   -lags
                %   -comptute_pos_pds
                %   -comptute_vel_pds
                %   -comptute_acc_pds
                %   -comptute_force_pds
                %   -comptute_dfdt_pds
                %   -comptute_dfdtdt_pds
                %   -data_offset

                interpolate_kinematics(timeseries);
                outstruct=build_outstruct(timeseries);
            case 'peak speed'
                %viable method_opts for the peak vel method:
                %   -lags
                %   -comptute_pos_pds
                %   -comptute_vel_pds
                %   -comptute_acc_pds
                %   -comptute_force_pds
                %   -comptute_dfdt_pds
                %   -comptute_dfdtdt_pds
                %   -data_offset
                %   -data_window

                % prune FR_timeseries to time windows around peaks in the
                % speed (computed as euclidean norm of vel variable) during trials
                
                %compute speed
                spd=sqrt(sum(vel(:,2:end).^2,2));
                [B,A]=butter(3,.1,'low');
                sspd=filtfilt(B,A,spd);
                %build output struct from data points around peak values in
                %speed
                outstruct=peak_value([vel(:,1),sspd]);

            case 'peak force'
                %viable method_opts for the peak dt method:
                %   -lags
                %   -comptute_pos_pds
                %   -comptute_vel_pds
                %   -comptute_acc_pds
                %   -comptute_force_pds
                %   -comptute_dfdt_pds
                %   -comptute_dfdtdt_pds
                %   -data_offset
                %   -data_window

                %build output struct from data points around peak values in
                %force
                forcemag=sqrt(sum(force(:,2:end).^2,2));
                [B,A]=butter(3,.2,'low');
                forcemag=filtfilt(B,A,forcemag);
                outstruct=peak_value([force(:,1),forcemag]);
            case 'peak dfdt'
                %viable method_opts for the peak dfdt method:
                %   -lags
                %   -comptute_pos_pds
                %   -comptute_vel_pds
                %   -comptute_acc_pds
                %   -comptute_force_pds
                %   -comptute_dfdt_pds
                %   -comptute_dfdtdt_pds
                %   -data_offset
                %   -data_window
                %build output struct from data points around peak values in
                %dfdt
                dfdtmag=sqrt(sum(dfdt(:,2:end).^2,2));
                [B,A]=butter(3,.2,'low');
                dfdtmag=filtfilt(B,A,dfdtmag);
                outstruct=peak_value([force(:,1),dfdtmag]);
            case 'peak acceleration'
                %viable method_opts for the peak acc method:
                %   -lags
                %   -comptute_pos_pds
                %   -comptute_vel_pds
                %   -comptute_acc_pds
                %   -comptute_force_pds
                %   -comptute_dfdt_pds
                %   -comptute_dfdtdt_pds
                %   -data_offset
                %   -data_window
                %build output struct from data points around peak values in
                %acc
                %compute speed
                spd=sqrt(sum(vel(:,2:end).^2,2));
                [B,A]=butter(3,.1,'low');
                sspd=filtfilt(B,A,spd);
                dsdt=gradient(sspd,vel(:,1));
                outstruct=peak_value([acc(:,1),dsdt]);
            case 'peak dfdtdt'
                %viable method_opts for the peak dfdtdt method:
                %   -lags
                %   -comptute_pos_pds
                %   -comptute_vel_pds
                %   -comptute_acc_pds
                %   -comptute_force_pds
                %   -comptute_dfdt_pds
                %   -comptute_dfdtdt_pds
                %   -data_offset
                %   -data_window
                %build output struct from data points around peak values in
                %dfdtdt
                dfdtdtmag=sqrt(sum(dfdtdt(:,2:end).^2,2));
                [B,A]=butter(3,.2,'low');
                dfdtdtmag=filtfilt(B,A,dfdtdtmag);
                outstruct=peak_value([force(:,1),dfdtdtmag]);
            case 'target onset'
                %viable method_opts for the target onset method:
                %   -lags
                %   -comptute_pos_pds
                %   -comptute_vel_pds
                %   -comptute_acc_pds
                %   -comptute_force_pds
                %   -comptute_dfdt_pds
                %   -comptute_dfdtdt_pds 
                %   -data_offset
                %   -data_window

                outstruct=sample_around_timepoints(target_onsets);
            case 'go cues'
                %viable method_opts for the target onset method:
                %   -lags
                %   -comptute_pos_pds
                %   -comptute_vel_pds
                %   -comptute_acc_pds
                %   -comptute_force_pds
                %   -comptute_dfdt_pds
                %   -comptute_dfdtdt_pds
                %   -data_offset
                %   -data_window

                outstruct=sample_around_timepoints(go_cues);
            case 'trials'
                %viable method_opts for the trials method:
                %   -lags
                %   -comptute_pos_pds
                %   -comptute_vel_pds
                %   -comptute_acc_pds
                %   -comptute_force_pds
                %   -comptute_dfdt_pds
                %   -comptute_dfdtdt_pds
                %   -data_offset
                
                T=trial_times;
                outstruct=sample_between_timepoints(T,timeseries);
            case 'target moves'
                %viable method_opts for the trials method:
                %   -lags
                %   -comptute_pos_pds
                %   -comptute_vel_pds
                %   -comptute_acc_pds
                %   -comptute_force_pds
                %   -comptute_dfdt_pds
                %   -comptute_dfdtdt_pds
                %   -data_offset
                
                T=move_times;
                outstruct=sample_between_timepoints(T,timeseries);
            case 'bumps'
                %viable method_opts for the bumps method:
                %   -lags
                %   -comptute_pos_pds
                %   -comptute_vel_pds
                %   -comptute_acc_pds
                %   -comptute_force_pds
                %   -comptute_dfdt_pds
                %   -comptute_dfdtdt_pds
                %   -data_offset

                if isempty(bump_times)
                    error('Parse_For_Tuning:NoBumps','The bumps method is not valid because the data set does not have bump times');
                end
                T=bump_times;
                outstruct=sample_between_timepoints(T,timeseries);
            otherwise
                 error('Parse_for_tuning:UnrecognizedMethod','The given method is not a valid parsing type')
        end
    


    function outstruct=peak_value(x)
        %computes the armdata struct for the peak velocity, peak dfdt, acc and
        %get number of targets
            num_targets=size(target_onsets,1);
        %loop through targets finding the speed peaks
            T=zeros(num_targets-1,1);%excludes the last point, which will be dealt with outside the loop
            for j=1:length(target_onsets)-1
                %just find first peak after target appearance
                inds=find(x(:,1)>target_onsets(j) & x(:,1)<target_onsets(j+1));
                [maxVal,maxInd]=extrema(x(inds));
                if isempty(maxInd)
                    warning('testAllTuning:NoMaxVel',strcat('Could not find a maxima for target onset# ',num2str(j)))
                    disp('skipping target')
                    continue
                end
                if maxInd(1)==1 & length(maxInd)>1
                    T(j)=inds(1)+maxInd(2);
                else
                    T(j)=inds(1)+maxInd(1);
                end

            end
            %deal with last point:

            targets_per_trial=bdf.TT(end,bdf.TT_hdr.num_targets);
            j=j+1;%adds a single index to the array for the last point
            test_end=bdf.TT(bdf.TT(:,7+2*targets_per_trial-1)==target_onsets(j),7+2*targets_per_trial);
            if ~isempty(test_end)
                inds=find(x(:,1)>target_onsets(j) & x(:,1)<test_end);
                [maxVal,maxInd]=extrema(x(inds));
                if isempty(maxInd)
                    warning('testAllTuning:NoMaxVel',strcat('Could not find a maxima for target onset# ',num2str(j)))
                    T=T(1:end-1);
                    disp('skipping target')
                elseif maxInd(1)==1 & length(maxInd)>1
                    T(j)=inds(1)+maxInd(2);
                else
                    T(j)=inds(1)+maxInd(1);
                end
            end
            outstruct=sample_around_timepoints(x(T,1));
    end

    function outstruct=sample_around_timepoints(T)
        %get firing rates in windows around the peak with the appropriate offset
        sample_times=[];
        for j=1:length(T)
            mask=((timeseries < (T(j)+data_window)) & ((timeseries)>T(j)));
            sample_times=[sample_times;timeseries(mask)];
        end
        interpolate_kinematics(sample_times);
        outstruct=build_outstruct(sample_times);
    end

    function outstruct=sample_between_timepoints(T,FR_timeseries)
        %get firing rates in windows around the peak with the appropriate offset
        sample_times=[];
        for j=1:length(T)
            mask=FR_timeseries > (T(j,1)) & (FR_timeseries)<T(j,2);
            sample_times=[sample_times;FR_timeseries(mask)];
        end
        interpolate_kinematics(sample_times);
        outstruct=build_outstruct(sample_times);
    end

    function interpolate_kinematics(sample_times)
        % interpolate to firing rate time points to the firing rate
        % timeseries with the specified offset
        good_data=interp1(pos(:,1),good_data,sample_times-data_offset);
        pos=interp1(pos(:,1),[pos(:,2:end),pos_lag_data],sample_times-data_offset);
        vel=interp1(vel(:,1),[vel(:,2:end),vel_lag_data],sample_times-data_offset);
        acc=interp1(acc(:,1),[acc(:,2:end),acc_lag_data],sample_times-data_offset);
        force=interp1(force(:,1),[force(:,2:end),force_lag_data],sample_times-data_offset);
        dfdt=interp1(dfdt(:,1),[dfdt(:,2:end),dfdt_lag_data],sample_times-data_offset);
        dfdtdt=interp1(dfdtdt(:,1),[dfdtdt(:,2:end),dfdtdt_lag_data],sample_times-data_offset);
        EMG=interp1(EMG(:,1),[EMG(:,2:end),EMG_lag_data],sample_times-data_offset);
    end
    function outstruct=build_outstruct(sample_times)
    %% adds data to the output struct 
        %check for NaN's and prune data appropriately
        if (find(isnan(pos))  |    find(isnan(vel))    |    find(isnan(acc))    |    find(isnan(force))    |    find(isnan(dfdt))    |    find(isnan(dfdtdt))    | find(isnan(EMG)))
            %positive lags will generate NaNs at the beginning of the data
            %series, negative lags will have them at the end. Since the user
            %can input both positive and negative lags, we must check for both

            %check for leading NaN's
            idx=find(lags==max(lags));
            %find the last leading NaN
            ipos=1;
            while isnan(pos(ipos,2*idx))
                ipos=ipos+1;
            end
            ivel=1;
            while isnan(vel(ivel,2*idx))
                ivel=ivel+1;
            end
            iacc=1;
            while isnan(acc(iacc,2*idx))
                iacc=iacc+1;
            end
            iforce=1;
            while isnan(force(iforce,2*idx))
                iforce=iforce+1;
            end
            idfdt=1;
            while isnan(dfdt(idfdt,2*idx))
                idfdt=idfdt+1;
            end
            idfdtdt=1;
            while isnan(dfdtdt(idfdtdt,2*idx))
                idfdtdt=idfdtdt+1;
            end
            iEMG=1;
            while isnan(EMG(iEMG,2*idx))
                iEMG=iEMG+1;
            end
            istart=max([ipos,ivel,iacc,iforce,idfdt,idfdtdt,iEMG])+1;

            %check for trailing NaN's
            idx=find(lags==min(lags));
            %find the index of the first trailing NaN
            ipos=length(pos(:,1));
            while isnan(pos(ipos,2*idx))
                ipos=ipos1-1;
            end
            ivel=length(vel(:,1));
            while isnan(vel(ivel,2*idx))
                ivel=ivel-1;
            end
            iacc=length(acc(:,1));
            while isnan(acc(iacc,2*idx))
                iacc=iacc-1;
            end
            iforce=length(force(:,1));
            while isnan(force(iforce,2*idx))
                iforce=iforce-1;
            end
            idfdt=length(dfdt(:,1));
            while isnan(dfdt(idfdt,2*idx))
                idfdt=idfdt-1;
            end
            idfdtdt=length(dfdtdt(:,1));
            while isnan(dfdtdt(idfdtdt,2*idx))
                idfdtdt=idfdtdt-1;
            end
            iEMG=length(EMG(:,1));
            while isnan(EMG(iEMG,2*idx))
                iEMG=iEMG-1;
            end

            iend=min([ipos,ivel,iacc,iforce,idfdt,idfdtdt,iEMG])-1;

            %trim off indices corresponding to leading NaNs
            pos=pos(istart:iend,:);
            vel=vel(istart:iend,:);
            acc=acc(istart:iend,:);
            force=force(istart:iend,:);
            dfdt=dfdt(istart:iend,:);
            dfdtdt=dfdtdt(istart:iend,:);
            EMG=EMG(istart:iend,:);
            good_data=good_data(istart:iend,:);
            sample_times=sample_times(istart:iend,:);

        end

        %compose armdata struct array for position
        outstruct.armdata(1).data=pos((good_data==1),:);
        outstruct.armdata(1).name='pos';
        outstruct.armdata(1).num_lags=num_lags;
        outstruct.armdata(1).num_base_cols=size(pos,2);
        if isfield(method_opts,'compute_pos_pds')
            outstruct.armdata(1).doPD=method_opts.compute_pos_pds;
        else
            outstruct.armdata(1).doPD=0;
        end
        %compose armdata cell array for velocity
        outstruct.armdata(2).data=vel((good_data==1),:);
        outstruct.armdata(2).name='vel';
        outstruct.armdata(2).num_lags=num_lags;
        outstruct.armdata(2).num_base_cols=size(vel,2);
        if isfield(method_opts,'compute_vel_pds')
            outstruct.armdata(2).doPD=method_opts.compute_vel_pds;
        else
            outstruct.armdata(2).doPD=1;
        end
        %compose armdata cell array for acceleration
        outstruct.armdata(3).data=acc((good_data==1),:);
        outstruct.armdata(3).name='acc';
        outstruct.armdata(3).num_lags=num_lags;
        outstruct.armdata(3).num_base_cols=size(acc,2);
        if isfield(method_opts,'compute_acc_pds')
            outstruct.armdata(3).doPD=method_opts.compute_acc_pds;
        else
            outstruct.armdata(3).doPD=0;
        end
        %compose armdata cell array for force
        outstruct.armdata(4).data=force((good_data==1),:);
        outstruct.armdata(4).name='force';
        outstruct.armdata(4).num_lags=num_lags;
        outstruct.armdata(4).num_base_cols=size(force,2);
        if isfield(method_opts,'compute_force_pds')
            outstruct.armdata(4).doPD=method_opts.compute_force_pds;
        else
            outstruct.armdata(4).doPD=0;
        end
        %compose armdata cell array for dfdt
        outstruct.armdata(5).data=dfdt((good_data==1),:);
        outstruct.armdata(5).name='dfdt';
        outstruct.armdata(5).num_lags=num_lags;
        outstruct.armdata(5).num_base_cols=size(dfdt,2);
        if isfield(method_opts,'compute_dfdt_pds')
            outstruct.armdata(5).doPD=method_opts.compute_dfdt_pds;
        else
            outstruct.armdata(5).doPD=0;
        end
        %compose armdata cell array for dfdtdt
        outstruct.armdata(6).data=dfdtdt((good_data==1),:);
        outstruct.armdata(6).name='dfdtdt';
        outstruct.armdata(6).num_lags=num_lags;
        outstruct.armdata(6).num_base_cols=size(dfdtdt,2);
        if isfield(method_opts,'compute_dfdtdt_pds')
            outstruct.armdata(6).doPD=method_opts.compute_dfdtdt_pds;
        else
            outstruct.armdata(6).doPD=0;
        end
        %compose armdata cell array for EMG
        outstruct.armdata(7).data=EMG((good_data==1),:);
        outstruct.armdata(7).name='EMG';
        outstruct.armdata(7).num_lags=num_lags;
        outstruct.armdata(7).num_base_cols=size(EMG,2);
        if isfield(method_opts,'compute_EMG_pds')
            outstruct.armdata(7).doPD=method_opts.compute_EMG_pds;
        else
            outstruct.armdata(7).doPD=0;
        end
        %compose FR field
        if use_FR
            FR=-1*ones(length(sample_times),length(which_units));
            for k=1:length(which_units)
                FR(:,k)=interp1(bdf.units(which_units(k)).FR(:,1),bdf.units(which_units(k)).FR(:,2),sample_times);
            end
        else
            FR=[];
        end
        if use_LFP
            PSD=-1*ones(length(sample_times),length(which_chans)*length(which_bands));
            for k=1:length(which_chans)
                PSD(:,(k-1)*which_bands+1:k*which_bands)=interp1(bdf.LFP.t,bdf.LFP.psd{which_chans(k)}(which_bands,:),sample_times);
            end
        else
            PSD=[];
        end
        
        outstruct.unit_mask=zeros(1,size(FR,2));
        outstruct.unit_mask(1:size(FR,2))=1;
        outstruct.LFP_mask=zeros(1,size(FR,2));
        outstruct.LFP_mask(1,size(FR,2)+1:size(FR,2)+size(PSD,2))=1;
        Neuraldata=[FR,PSD];
        outstruct.FR=[Neuraldata((good_data==1),:)];
        outstruct.unit_ids=unit_ids;
        outstruct.LFP_ids=LFP_ids;
        %compose the time vector
        outstruct.T=sample_times((good_data==1),:);
        %compose unit list field
        outstruct.which_units=which_units;
        %compose list of lags
        outstruct.lags=lags;
    end
end