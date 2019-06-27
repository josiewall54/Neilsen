close all; clear all; home;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Wrapper script to convert one or several .plx files to a 
%   .mat file of binned data.
%
% PARAMETERS:
%   directory.rawdata     : Directory with .plx files
%   directory.database    : Directory where .mat binned files will be saved
%   binSize               : Bin Size desired
%   sorted                : Whether we have sorted spikes on a .plx
%
% OUTPUTS:
%   nameoffile_binned.mat : the binned file! Yessss!
%
% TIPS:
%
% Written by Pablo Tostado & Maria Jantz. Updated May 2017
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Add directories to path
myPath = 'C:\Users\mct519\Documents\Data analyses\Neilsen\LFP_Analysis';

% In case the plexon routines are not already in the Path:
plexonRoutinesPath = [myPath '\rat_bmi-master\plexon_import'];
addpath(genpath(plexonRoutinesPath));

% Set the directories' paths:
directory = [myPath '\rat_bmi-master\'];
directories.rawdata = [directory 'Data_Intracortical\N5\17-07-10'];
directories.database = [directory 'Data_Intracortical'];
cd(directories.rawdata)

% PARAMS: Specify desired bin size and if file is sorted
binSize = 0.05;
sorted = 0; % Change to 1 if you're using sorted.plx file, if unsorted, set to 0

%FILENAME : Be specific if you only want one certain file
SPIKEtargetfile = 'N5_170710_noobstacle_1.plx';        % !Different from original file if sorted
EMGtargetfile = 'N5_170710_noobstacle_1.plx';          % EMGs are not saved in the sorted file after offline sorting
viconCh = 16;   % this has the TTL signal indicating when Vicon is acquiring data

%% Find the offset between the Vicon and the Plexon acquisition files

filenames = dir(SPIKEtargetfile);
filename = strtok(filenames(1).name,'.');  % get rid of the extension for the next file    
Vicon_sync = import_plexon_analog([pwd '\'], filename, viconCh); %Import the Vicon synchronizing channel

% Keep only data the data when Vicon was recording:
viconChannel = find(Vicon_sync.channel == viconCh);

plxVicon = Vicon_sync.data(viconChannel,:) > 1;
plxFreq = Vicon_sync.freq(1);

ind = find(plxVicon);  % find the samples when Vicon is collecting data
ViconSync.OnsetSample = ind(1);  % the Plexon sample where Vicon starts  - assuming only a single period of collection in each file
ViconSync.OnsetTime = ViconSync.OnsetSample/plxFreq;  % the time in the Plexon file when Vicon starts
ViconSync.OffsetSample = ind(end);   % the sample where the Vicon stops
ViconSync.OffsetTime = ViconSync.OffsetSample/plxFreq;  % the time where the Vicon stops

%% Read in the spike data

filenames = dir(SPIKEtargetfile);
fileind = 1;  % vestigial?
filename = filenames(fileind).name;

indsUnderscore = strfind(filename,'_');
indsPoint = strfind(filename,'.');

animal = filename(1:indsUnderscore(1)-1);
date   = filename(indsUnderscore(1)+1:indsPoint(1)-1);

[num2str(fileind) '  ' num2str(length(filenames)) '  ' animal '  ' date];

cd(directories.rawdata)

%Load neural data and bin it.
plexondata = load_plexondata_spikes(filename, binSize, sorted);
plexondata = align_plexon_spikes(plexondata,ViconSync);  % uses the info in ViconSync to modify the spike data in plexondata so the streams are aligned


%% read in EMG data
filenames = dir(EMGtargetfile);
filename = filenames(fileind).name;

%Load EMG data and bin it.
EMG_params.binsize = binSize; EMG_params.EMG_lp = 5; EMG_params.EMG_hp = 50;
[emgdatabin, emgdata] = load_plexondata_EMG_v2(filename, EMG_params);
plexondata.emgdata = emgdata;

plexondata = align_plexon_emgs(plexondata,ViconSync);

% ADD CALL TO VICON DATA. !!! This functionality has not been fixed, might not work.
% plexondata.viconsync = load_plexon_vicondata(animal,date);

%Create folder in Database to store animal info
animalDir = [directories.database '\' animal '_' date];
if ~exist(animalDir, 'dir')
    mkdir(animalDir)
end

cd(animalDir)
save([animal '_' date '_binned.mat'],'plexondata')
end


%clear; clc;