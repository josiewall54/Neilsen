 
function [kinData,kinTreadmillData] = importVicon(fullFilePath)
 
% pathName = '/Volumes/fsmresfiles/Basic_Sciences/Phys/L_MillerLab/data/Rats/kinematics/E1/'; 
% fileName = '17-05-2602_no_obstacle_speed9';
% path     = [data_dir filenameKin];
 
%if you get a "Marker not found" error check that the names below all match
%the names in the first row of the csv file, which are formatted as
%"tdmName:tdmMk" and "ratName:ratMk"
% tdmName = 'treadmill';
% tdmMks  = {'treadmill1', 'treadmill2', 'treadmill3', 'treadmill4'};
% 
% ratName = 'rat'; 
% ratMks  = {'hip_top', 'hip_middle', 'hip_bottom', ...
%     'femur_mid', 'knee', 'tibia_mid', 'heel', 'foot_mid', 'toe'};
% 
% markersetnames = {'treadmill','rat','obstacles'};
 
%this line does the importing
[events,markersets] = ...
    importViconData_v2(fullFilePath);   % ratName,tdmName,ratMks,tdmMks);
 
 
 
%% 
fnames = fieldnames(markersets);
if sum(strcmp(fnames,'rat'))
    rat = markersets.rat;
else
    disp('no markers called rat in Vicon file')
    for ii = 1:length(fnames)
        if isstruct(markersets.(fnames{ii}))
            subfnames = fieldnames(markersets.(fnames{ii}));
            ind = strncmp(subfnames,'hip',3);
            if sum(ind)
                disp('I think I found the rat subject in here');
                disp(['it''s called ' fnames{ii}])
                ratind = find(ind);
                rat = markersets.(fnames{ii});
            end
        end
    end
end
 
        
rlocs.freq = markersets.freq;
rlocs.names = rat.labels; 
rlocs.x = []; rlocs.y = []; rlocs.z = [];
for i=1:length(rat.labels)
    mk = rat.(rat.labels{i});
%     rlocs.names{end+1} = rat.labelsMks{i};
    rlocs.x(:, end+1) = mk(:, 1);
    rlocs.y(:, end+1) = mk(:, 2);
    rlocs.z(:, end+1) = mk(:, 3);
end
 
fnames = fieldnames(markersets);
if sum(strcmp(fnames,'treadmill'))
    tread = markersets.treadmill;
else
    disp('no markers called treadmill in Vicon file')
    for ii = 1:length(fnames)
        if isstruct(markersets.(fnames{ii}))
            subfnames = fieldnames(markersets.(fnames{ii}));
            ind = strncmp(subfnames,'tread',5);
            if sum(ind)
                disp('I think I found treadmill marker in here');
                disp(['it''s called ' fnames{ii}])
                ratind = find(ind);
                tread = markersets.(fnames{ii});
            end
        end
    end
end
 
        
tlocs.freq = markersets.freq;
tlocs.names = tread.labels; 
tlocs.x = []; tlocs.y = []; tlocs.z = [];
for i=1:length(tread.labels)
    mk = tread.(tread.labels{i});
%     rlocs.names{end+1} = rat.labelsMks{i};
    tlocs.x(:, end+1) = mk(:, 1);
    tlocs.y(:, end+1) = mk(:, 2);
    tlocs.z(:, end+1) = mk(:, 3);
end
kinData = rlocs;
kinTreadmillData = tlocs;
end
 

