function [Go_Rew_ts_w_EMGs] = get_expected_EMGs_MG(tt, EMGpatterns)

    % This function returns a matrix of [ts emg1 emg2 ... emgn]
    % datastruct can be either a BDF or a binnedData structure
    %
    % ts is the time at which a 'Go_Cue' or a 'Reward' word was issue
    % emg1, emg2, ..., emgn consist of the expected EMG amplitude in each
    % of the muscles for the respectvie ts. This fixed value depends on the
    % behavior, the gadget, the target, etc.
    %
    % Go_Rew_ts_w_EMGs is an array that provides the information as to what EMG
    % value is to be expected given the gadget and target
    % It is a three dimensional array of size numTargets+1 x numEMG x numGadgedts.
    %
    % Note: for "Go_Cue"s, the expected EMG values are assumed to be in the first
    % row of EMGpatterns, and the following rows (2:end) correspond to tgt1:tgtn
    %
    % Note 2: the arrangement of the MG trial table is as follow:
    %    1: Start time
    %    2: Hand on Touch Pad
    %    3: Go cue (word = Go | Catch)
    %    4: Trial Type (0:Go, 1:Catch)
    %    5: Gadget ID (0:3)
    %    6: Target ID (0:15)
    %    7: Target UL X
    %    8: Target UL Y
    %    9: Target LR X
    %    10:Target LR Y
    %    11:Trial End time
    %    12:Trial result        -- R, A, F, or I
    
    targets = unique(tt(tt(:,6)>=0,6)); %skip if tgt = -1, something was wrong
    gadgets = unique(tt(tt(:,5)>=0,5)); %skip if gdt = -1, something was wrong
    
    % Find Go and Reward rows in tt :
    Go = find(tt(:,3) >= 0); %sometimes Go ts may be = -1 in tt if something was wrong
    Rewards = find( tt(:,12)==double('R') );

    numRew = length(Rewards);
    numEMGs = size(EMGpatterns,2);
    numGo = length(Go);
    Go_ts_w_EMGs = zeros(numGo,numEMGs+1);
    Rew_ts_w_EMGs = zeros(numRew,numEMGs+1);

    % Assign expected EMGs for Go
    % first row of EMGpatterns. Even if EMGpattern is 3D, 3rd dim is for different gadgets.
    % it should all be the same for the first row, so use gdt 1 (index 1 of dim 3)
    Go_ts_w_EMGs = [tt(Go,3) repmat(EMGpatterns(1,:,1),numGo,1)];

    for i = 1:numRew
        %Assign expected EMGs for each Reward Trial:
        tgtIdx = find(targets==tt(Rewards(i),6))+1; %first line if for Go, so +1 for 2-indexed tgtIdx
        gdtIdx = find(gadgets==tt(Rewards(i),5)); %1-indexed gdtIdx
        Rew_ts_w_EMGs(i,:) = [tt(Rewards(i),11) EMGpatterns(tgtIdx,:,gdtIdx)];
    end

    Go_Rew_ts_w_EMGs = sortrows([Go_ts_w_EMGs;Rew_ts_w_EMGs],1);
   
