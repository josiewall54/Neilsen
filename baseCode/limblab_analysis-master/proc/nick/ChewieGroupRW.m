addpath('\\165.124.111.182\limblab\user_folders\Rachel\FINAL Data Sets\Chewie\RW');

% hybrid decoder files (CRW2)
load('statsC0111002.mat');
load('statsC0111004.mat');
load('statsC0111006.mat');
load('statsC0112004.mat');
load('statsC0112006.mat');
load('statsC0112008.mat');
load('statsC0117003.mat');
load('statsC0117005.mat');
load('statsC0118008.mat');
load('statsC0118010.mat');
load('statsC0119007.mat');
load('statsC0119010.mat');
% load('statsC0120006.mat'); % no paired file
load('statsC0120008.mat');

% standard decoder files (CRW1)
load('statsC0111003.mat');
load('statsC0111005.mat');
load('statsC0111007.mat');
load('statsC0112003.mat'); % still waiting...
load('statsC0112005.mat');
load('statsC0112007.mat');
load('statsC0117002.mat');
load('statsC0117004.mat');
load('statsC0118007.mat');
load('statsC0118009.mat');
load('statsC0119006.mat');
load('statsC0119008.mat');
% load('statsC0120007.mat'); % no target info
load('statsC0120009.mat');

% hybrid decoder metrics
CRW2_num_entries = [statsC0111002.num_entries' statsC0111004.num_entries' ...
    statsC0111006.num_entries' statsC0112004.num_entries' statsC0112006.num_entries' ...
    statsC0112008.num_entries' statsC0117003.num_entries' statsC0117005.num_entries' ...
    statsC0118008.num_entries' statsC0118010.num_entries' statsC0119007.num_entries' ...
    statsC0119010.num_entries' statsC0120008.num_entries'];

CRW2_time2reward = [statsC0111002.time2reward statsC0111004.time2reward ...
    statsC0111006.time2reward statsC0112004.time2reward statsC0112006.time2reward ...
    statsC0112008.time2reward statsC0117003.time2reward statsC0117005.time2reward ...
    statsC0118008.time2reward statsC0118010.time2reward statsC0119007.time2reward ...
    statsC0119010.time2reward statsC0120008.time2reward];

CRW2_time2targ = [statsC0111002.time2target' statsC0111004.time2target' ...
    statsC0111006.time2target' statsC0112004.time2target' statsC0112006.time2target' ...
    statsC0112008.time2target' statsC0117003.time2target' statsC0117005.time2target' ...
    statsC0118008.time2target' statsC0118010.time2target' statsC0119007.time2target' ...
    statsC0119010.time2target' statsC0120008.time2target'];

CRW2_dial_in = [statsC0111002.dial_in statsC0111004.dial_in ...
    statsC0111006.dial_in statsC0112004.dial_in statsC0112006.dial_in ...
    statsC0112008.dial_in statsC0117003.dial_in statsC0117005.dial_in ...
    statsC0118008.dial_in statsC0118010.dial_in statsC0119007.dial_in ...
    statsC0119010.dial_in statsC0120008.dial_in];

CRW2_movepatheff = [statsC0111002.pathlength(5,:) statsC0111004.pathlength(5,:) ...
    statsC0111006.pathlength(5,:) statsC0112004.pathlength(5,:) statsC0112006.pathlength(5,:) ...
    statsC0112008.pathlength(5,:) statsC0117003.pathlength(5,:) statsC0117005.pathlength(5,:) ...
    statsC0118008.pathlength(5,:) statsC0118010.pathlength(5,:) statsC0119007.pathlength(5,:) ...
    statsC0119010.pathlength(5,:) statsC0120008.pathlength(5,:)];

% CRW2_movepatheff = [statsC0111002.pathlength(1,:) statsC0111004.pathlength(1,:) ...
%     statsC0111006.pathlength(1,:) statsC0112004.pathlength(1,:) statsC0112006.pathlength(1,:) ...
%     statsC0112008.pathlength(1,:) statsC0117003.pathlength(1,:) statsC0117005.pathlength(1,:) ...
%     statsC0118008.pathlength(1,:) statsC0118010.pathlength(1,:) statsC0119007.pathlength(1,:) ...
%     statsC0119010.pathlength(1,:) statsC0120008.pathlength(1,:)]/8;

CRW2_totpatheff = [statsC0111002.pathlength(6,:) statsC0111004.pathlength(6,:) ...
    statsC0111006.pathlength(6,:) statsC0112004.pathlength(6,:) statsC0112006.pathlength(6,:) ...
    statsC0112008.pathlength(6,:) statsC0117003.pathlength(6,:) statsC0117005.pathlength(6,:) ...
    statsC0118008.pathlength(6,:) statsC0118010.pathlength(6,:) statsC0119007.pathlength(6,:) ...
    statsC0119010.pathlength(6,:) statsC0120008.pathlength(6,:)];

% CRW2_totpatheff = [statsC0111002.pathlength(3,:) statsC0111004.pathlength(3,:) ...
%     statsC0111006.pathlength(3,:) statsC0112004.pathlength(3,:) statsC0112006.pathlength(3,:) ...
%     statsC0112008.pathlength(3,:) statsC0117003.pathlength(3,:) statsC0117005.pathlength(3,:) ...
%     statsC0118008.pathlength(3,:) statsC0118010.pathlength(3,:) statsC0119007.pathlength(3,:) ...
%     statsC0119010.pathlength(3,:) statsC0120008.pathlength(3,:)]/8;

CRW2_var = [statsC0111002.vardata statsC0111004.vardata ...
    statsC0111006.vardata statsC0112004.vardata statsC0112006.vardata ...
    statsC0112008.vardata statsC0117003.vardata statsC0117005.vardata ...
    statsC0118008.vardata statsC0118010.vardata statsC0119007.vardata ...
    statsC0119010.vardata statsC0120008.vardata];

%standard decoder metrics
CRW1_num_entries = [statsC0111003.num_entries' statsC0111005.num_entries' ...
    statsC0111007.num_entries' statsC0112003.num_entries' statsC0112005.num_entries' ...
    statsC0112007.num_entries' statsC0117002.num_entries' statsC0117004.num_entries' ...
    statsC0118007.num_entries' statsC0118009.num_entries' statsC0119006.num_entries' ...
    statsC0119008.num_entries' statsC0120009.num_entries'];

CRW1_time2reward = [statsC0111003.time2reward statsC0111005.time2reward ...
    statsC0111007.time2reward statsC0112003.time2reward statsC0112005.time2reward ...
    statsC0112007.time2reward statsC0117002.time2reward statsC0117004.time2reward ...
    statsC0118007.time2reward statsC0118009.time2reward statsC0119006.time2reward ...
    statsC0119008.time2reward statsC0120009.time2reward];

CRW1_time2targ = [statsC0111003.time2target' statsC0111005.time2target' ...
    statsC0111007.time2target' statsC0112003.time2target' statsC0112005.time2target' ...
    statsC0112007.time2target' statsC0117002.time2target' statsC0117004.time2target' ...
    statsC0118007.time2target' statsC0118009.time2target' statsC0119006.time2target' ...
    statsC0119008.time2target' statsC0120009.time2target'];

CRW1_dial_in = [statsC0111003.dial_in statsC0111005.dial_in ...
    statsC0111007.dial_in statsC0112003.dial_in statsC0112005.dial_in ...
    statsC0112007.dial_in statsC0117002.dial_in statsC0117004.dial_in ...
    statsC0118007.dial_in statsC0118009.dial_in statsC0119006.dial_in ...
    statsC0119008.dial_in statsC0120009.dial_in];

CRW1_movepatheff = [statsC0111003.pathlength(5,:) statsC0111005.pathlength(5,:) ...
    statsC0111007.pathlength(5,:) statsC0112003.pathlength(5,:) statsC0112005.pathlength(5,:) ...
    statsC0112007.pathlength(5,:) statsC0117002.pathlength(5,:) statsC0117004.pathlength(5,:) ...
    statsC0118007.pathlength(5,:) statsC0118009.pathlength(5,:) statsC0119006.pathlength(5,:) ...
    statsC0119008.pathlength(5,:) statsC0120009.pathlength(5,:)];

% CRW1_movepatheff = [statsC0111003.pathlength(1,:) statsC0111005.pathlength(1,:) ...
%     statsC0111007.pathlength(1,:) statsC0112003.pathlength(1,:) statsC0112005.pathlength(1,:) ...
%     statsC0112007.pathlength(1,:) statsC0117002.pathlength(1,:) statsC0117004.pathlength(1,:) ...
%     statsC0118007.pathlength(1,:) statsC0118009.pathlength(1,:) statsC0119006.pathlength(1,:) ...
%     statsC0119008.pathlength(1,:) statsC0120009.pathlength(1,:)]/8;

CRW1_totpatheff = [statsC0111003.pathlength(6,:) statsC0111005.pathlength(6,:) ...
    statsC0111007.pathlength(6,:) statsC0112003.pathlength(6,:) statsC0112005.pathlength(6,:) ...
    statsC0112007.pathlength(6,:) statsC0117002.pathlength(6,:) statsC0117004.pathlength(6,:) ...
    statsC0118007.pathlength(6,:) statsC0118009.pathlength(6,:) statsC0119006.pathlength(6,:) ...
    statsC0119008.pathlength(6,:) statsC0120009.pathlength(6,:)];

% CRW1_totpatheff = [statsC0111003.pathlength(3,:) statsC0111005.pathlength(3,:) ...
%     statsC0111007.pathlength(3,:) statsC0112003.pathlength(3,:) statsC0112005.pathlength(3,:) ...
%     statsC0112007.pathlength(3,:) statsC0117002.pathlength(3,:) statsC0117004.pathlength(3,:) ...
%     statsC0118007.pathlength(3,:) statsC0118009.pathlength(3,:) statsC0119006.pathlength(3,:) ...
%     statsC0119008.pathlength(3,:) statsC0120009.pathlength(3,:)]/8;

CRW1_var = [statsC0111003.vardata statsC0111005.vardata ...
    statsC0111007.vardata statsC0112003.vardata statsC0112005.vardata ...
    statsC0112007.vardata statsC0117002.vardata statsC0117004.vardata ...
    statsC0118007.vardata statsC0118009.vardata statsC0119006.vardata ...
    statsC0119008.vardata statsC0120009.vardata];
