addpath('\\165.124.111.182\limblab\user_folders\Rachel\FINAL Data Sets\Mini\RW');

% hybrid decoder files (MRW2)
load('stats661.mat');
load('stats663.mat');
load('stats665.mat');
% load('stats675.mat'); % short file
% load('stats677.mat'); % no target info
load('stats691.mat');
load('stats694.mat');
load('stats700.mat');
load('stats703.mat');
load('stats709.mat');
load('stats711.mat');
load('stats719.mat');
load('stats721.mat');

% standard decoder files (MRW1)
load('stats660.mat');
load('stats662.mat');
load('stats664.mat');
% load('stats674.mat'); % short file
% load('stats676.mat'); % no paired file
load('stats690.mat');
load('stats692.mat');
load('stats701.mat');
load('stats704.mat');
load('stats708.mat');
load('stats710.mat');
load('stats720.mat');
load('stats722.mat');

% hybrid decoder metrics
MRW2_num_entries = [stats661.num_entries' stats663.num_entries' ...
    stats665.num_entries' stats691.num_entries' stats694.num_entries' ...
    stats700.num_entries' stats703.num_entries' stats709.num_entries' ...
    stats711.num_entries' stats719.num_entries' stats721.num_entries'];

MRW2_time2reward = [stats661.time2reward stats663.time2reward ...
    stats665.time2reward stats691.time2reward stats694.time2reward ...
    stats700.time2reward stats703.time2reward stats709.time2reward ...
    stats711.time2reward stats719.time2reward stats721.time2reward];

MRW2_time2targ = [stats661.time2target' stats663.time2target' ...
    stats665.time2target' stats691.time2target' stats694.time2target' ...
    stats700.time2target' stats703.time2target' stats709.time2target' ...
    stats711.time2target' stats719.time2target' stats721.time2target'];

MRW2_dial_in = [stats661.dial_in stats663.dial_in ...
    stats665.dial_in stats691.dial_in stats694.dial_in ...
    stats700.dial_in stats703.dial_in stats709.dial_in ...
    stats711.dial_in stats719.dial_in stats721.dial_in];

MRW2_movepatheff = [stats661.pathlength(5,:) stats663.pathlength(5,:) ...
    stats665.pathlength(5,:) stats691.pathlength(5,:) stats694.pathlength(5,:) ...
    stats700.pathlength(5,:) stats703.pathlength(5,:) stats709.pathlength(5,:) ...
    stats711.pathlength(5,:) stats719.pathlength(5,:) stats721.pathlength(5,:)];

% MRW2_movepatheff = [stats661.pathlength(1,:) stats663.pathlength(1,:) ...
%     stats665.pathlength(1,:) stats691.pathlength(1,:) stats694.pathlength(1,:) ...
%     stats700.pathlength(1,:) stats703.pathlength(1,:) stats709.pathlength(1,:) ...
%     stats711.pathlength(1,:) stats719.pathlength(1,:) stats721.pathlength(1,:)]/8;

MRW2_totpatheff = [stats661.pathlength(6,:) stats663.pathlength(6,:) ...
    stats665.pathlength(6,:) stats691.pathlength(6,:) stats694.pathlength(6,:) ...
    stats700.pathlength(6,:) stats703.pathlength(6,:) stats709.pathlength(6,:) ...
    stats711.pathlength(6,:) stats719.pathlength(6,:) stats721.pathlength(6,:)];

% MRW2_totpatheff = [stats661.pathlength(3,:) stats663.pathlength(3,:) ...
%     stats665.pathlength(3,:) stats691.pathlength(3,:) stats694.pathlength(3,:) ...
%     stats700.pathlength(3,:) stats703.pathlength(3,:) stats709.pathlength(3,:) ...
%     stats711.pathlength(3,:) stats719.pathlength(3,:) stats721.pathlength(3,:)]/8;

MRW2_var = [stats661.vardata stats663.vardata ...
    stats665.vardata stats691.vardata stats694.vardata ...
    stats700.vardata stats703.vardata stats709.vardata ...
    stats711.vardata stats719.vardata stats721.vardata];

%standard decoder metrics
MRW1_num_entries = [stats660.num_entries' stats662.num_entries' ...
    stats664.num_entries' stats690.num_entries' stats692.num_entries' ...
    stats701.num_entries' stats704.num_entries' stats708.num_entries' ...
    stats710.num_entries' stats720.num_entries' stats722.num_entries'];

MRW1_time2reward = [stats660.time2reward stats662.time2reward ...
    stats664.time2reward stats690.time2reward stats692.time2reward ...
    stats701.time2reward stats704.time2reward stats708.time2reward ...
    stats710.time2reward stats720.time2reward stats722.time2reward];

MRW1_time2targ = [stats660.time2target' stats662.time2target' ...
    stats664.time2target' stats690.time2target' stats692.time2target' ...
    stats701.time2target' stats704.time2target' stats708.time2target' ...
    stats710.time2target' stats720.time2target' stats722.time2target'];

MRW1_dial_in = [stats660.dial_in stats662.dial_in ...
    stats664.dial_in stats690.dial_in stats692.dial_in ...
    stats701.dial_in stats704.dial_in stats708.dial_in ...
    stats710.dial_in stats720.dial_in stats722.dial_in];

MRW1_movepatheff = [stats660.pathlength(5,:) stats662.pathlength(5,:) ...
    stats664.pathlength(5,:) stats690.pathlength(5,:) stats692.pathlength(5,:) ...
    stats701.pathlength(5,:) stats704.pathlength(5,:) stats708.pathlength(5,:) ...
    stats710.pathlength(5,:) stats720.pathlength(5,:) stats722.pathlength(5,:)];

% MRW1_movepatheff = [stats660.pathlength(1,:) stats662.pathlength(1,:) ...
%     stats664.pathlength(1,:) stats690.pathlength(1,:) stats692.pathlength(1,:) ...
%     stats701.pathlength(1,:) stats704.pathlength(1,:) stats708.pathlength(1,:) ...
%     stats710.pathlength(1,:) stats720.pathlength(1,:) stats722.pathlength(1,:)]/8;

MRW1_totpatheff = [stats660.pathlength(6,:) stats662.pathlength(6,:) ...
    stats664.pathlength(6,:) stats690.pathlength(6,:) stats692.pathlength(6,:) ...
    stats701.pathlength(6,:) stats704.pathlength(6,:) stats708.pathlength(6,:) ...
    stats710.pathlength(6,:) stats720.pathlength(6,:) stats722.pathlength(6,:)];

% MRW1_totpatheff = [stats660.pathlength(3,:) stats662.pathlength(3,:) ...
%     stats664.pathlength(3,:) stats690.pathlength(3,:) stats692.pathlength(3,:) ...
%     stats701.pathlength(3,:) stats704.pathlength(3,:) stats708.pathlength(3,:) ...
%     stats710.pathlength(3,:) stats720.pathlength(3,:) stats722.pathlength(3,:)]/8;

MRW1_var = [stats660.vardata stats662.vardata ...
    stats664.vardata stats690.vardata stats692.vardata ...
    stats701.vardata stats704.vardata stats708.vardata ...
    stats710.vardata stats720.vardata stats722.vardata];
