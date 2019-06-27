%IMPORTVICONDATA imports comma-separated-values (csv) files obtained with
%the Vicon into Matlab. For the moment, this function is not general, and
%it assumes there is a subject Rat and a subject Treadmill.
%
%[ events, rat, treadmill ] = importViconData( path,        ...
%                                            ratName, tdmName,       ...
%                                            ratMarkers, tdmMarkers, ...
%                                            nColEv)
%dd
%INPUTS:
%
%path: Path and filename of the csv file (the extension .csv is required)
%ratName: String that identifies the subject Rat
%tdmName: String that identifies the subject Treadmill
%ratMarkers: Cell of strings with names of the markers in the subject Rat 
%tdmMarkers: Cell of strings with names of the markers in the subject
%Treadmill
%nColEv: number of columns that contain information about the events (if
%any). This parameter is optional. If not provided, its default value is 5.
%
%OUTPUTS:
%
%events: struct that contains information about the events (if any), as
%defined on Nexus. The field events.time is a Ne-by-1 column matrix with
%the time of occurance of the Ne events.
%rat: struct that contains information on the subject Rat. There is a field
%for each <marker>. Each rat.<marker> field is a N-by-3 matrix with
%the X,Y,Z coordinates of <marker> for N timestam. The fields rat.frame and
%rat.subframes are N-by-1 column vectors with the frame and the subframe
%of each sample in rat.<marker>.
%treadmill:struct that contains information on the subject Treadmill. There 
%is a field for each <marker>. Each treadmill.<marker> field is a N-by-3 
%matrix with the X,Y,Z coordinates of <marker> for N timestam. The fields 
%treadmill.frame and treadmill.subframes are N-by-1 column vectors with the 
%frame and the subframe of each sample in rat.<marker>.
%
%Author: Cristiano Alessandro (cristiano.alessandro@northwestern.edu)
%Date: April 13 2016
%Licence: GNU GPL


function [ events, allmarkers ] = importViconData_v2( path,markersetnames)
                                            
% ratName, tdmName,       ...
%                                             ratMarkers, tdmMarkers, ...
%                                             nColEv)

disp(['reading ' path])
[num,txt,raw] = xlsread(path);  % read the csv file

% find where the events and trajectory information is - for now, I'm
% ignoring the events
tmp = raw(:,1);
idx_ev2 = cellfun(@(x)strcmp(x,'Events'),tmp); % find where the events are located
idx_tj2 = cellfun(@(x)strcmp(x,'Trajectories'),tmp);  % find where the trajectories are located

markerlabel_row = find(idx_tj2)+2;  % the row that has the marker labels
markerdata_row = markerlabel_row+3;   % the row that starts the marker data

allmarkers.freq = raw{markerlabel_row-1,1};   % get the frequency, frame and subframe numbers
allmarkers.frames = cell2mat(raw(markerdata_row:end,1));
allmarkers.subframes = cell2mat(raw(markerdata_row:end,2));

% find the name of the different markersets, along with the markers
[nrow,ncol] = size(raw);
coln = 1; allsetname = {}; allmarkerlabels = {};
while coln < ncol  % go through each column
    current = raw{markerlabel_row,coln};   % look at the string in this column of the marker labels
    if ~isnan(current) & ~isempty(current)  % if there's an entry
        [setname, marker] = strtok(current,':');   % break up the string around the colon
        allsetname{end+1} = setname;          % to the left is the subject(markerset) name
        allmarkerlabels{end+1} = marker(2:end);   % to the right is the name of the marker
    end
    coln = coln + 1;
end

% now create the structure with the different marker sets
markersets = unique(allsetname);  % the different markerset names
nmarkersets = length(markersets);   % the number of different markersets
for ii = 1:nmarkersets    % go through the different markersets
    ind = find(strcmp(markersets{ii},allsetname));   % find the elements for that markerset
    labels = allmarkerlabels(ind);             % find all the labels for the markers in that set
    fieldname = strrep(markersets{ii},' ','_');
    fieldname = strrep(fieldname,'+','_');
    if ~isempty(str2num(fieldname))
        fieldname = 'Dummy';
    end       
    allmarkers.(fieldname).labels = labels;  % make the substructure for that markerset
end

% ok, now go through and find the data for each marker and put it in the
% right structure
markerlabel_row_str = raw(markerlabel_row,:);  
for ii = 1:nmarkersets    % iterate of the number of markersets
    fieldname = strrep(markersets{ii},' ','_');
    fieldname = strrep(fieldname,'+','_');
    if ~isempty(str2num(fieldname))
        fieldname = 'Dummy';
    end       
    labels = allmarkers.(fieldname).labels;    % the labels of the markers in this markerset
    nlabels = length(labels); 
    for jj = 1:nlabels   % go over the different markernames
        fullmarkername = [markersets{ii} ':' labels{jj}];  % this is the full name of this marker
        coln = find(strcmp(fullmarkername,markerlabel_row_str));  % find the columns for this marker
        dat = raw((markerdata_row):end,coln:(coln+2));  % the xyz data for this marker
        labelname = strrep(labels{jj},' ','_');
        labelname = strrep(labelname,'+','_');
        if ~isempty(str2num(fieldname))
            labelname = 'Dummy';
        end
        allmarkers.(fieldname).(labelname) = cell2mat(dat);  % assign it into the structure
    end
end

events = [];


% 
% rat.f        = str2double(tmp{idx_tj+1});
% rat.frame    = cellfun(@(x)str2double(x),tmp(idx_tj+5:end));
% rat.subframe = cellfun(@(x)str2double(x),C{1,2}(idx_tj+5:end));
% 
% 
% 
%     nMarkers   = length(ratMarkers) + length(tdmMarkers);
% 
%     if nargin<6
%         nColEv = 5;          % #columns events
%     end
%     nColTj = nMarkers*3 + 2; % #columns trajectories (xyz for each marker + 
%                              %                        Frame and Subframe)
% 
%     % Open file
%     fileID = fopen(path);
% 
%     if fileID ==-1
%         error('File %s not found!\n',path);
%     end
% 
%     % Read 32 columns of strings and put them in columns
%     formatString = '%s';
%     for j=1:max([nColEv nColTj])-1
%         formatString = strcat(formatString,' %s');
%     end
% 
%     C = textscan(fileID,formatString, 'Delimiter',',','EmptyValue',NaN);
% 
% 
%     %C = textscan(fileID,['%s %s %s %s %s %s %s %s %s %s' ...
%     %                     '%s %s %s %s %s %s %s %s %s %s' ...
%     %                     '%s %s %s %s %s %s %s %s %s %s %s %s'], ...
%     %                     'Delimiter',',','EmptyValue',NaN);
% 
%     fclose(fileID);
% 
%     tmp = C{1,1};
%     idx_ev = cellfun(@(x)strcmp(x,'Events'),tmp);
%     idx_tj = cellfun(@(x)strcmp(x,'Trajectories'),tmp);
% 
%     tmp2 = raw(:,1);
%     idx_ev2 = cellfun(@(x)strcmp(x,'Events'),tmp2);
%     idx_tj2 = cellfun(@(x)strcmp(x,'Trajectories'),tmp2);
% 
% 
%     % There must be trajectory data
%     if ~any(idx_tj)
%         error('No data!');
%     end
%     idx_tj = find(idx_tj);
% 
%     % If there are events
%     if any(idx_ev)
%         idx_ev          = find(idx_ev);
%         events.f        = str2double(tmp{idx_ev+1});
%         events.colNames = cellfun(@(x)x(idx_ev+2),C(1,1:nColEv));
%         events.data     = cellfun(@(x)x(idx_ev+3:idx_tj-1), C(1,1:nColEv), ...
%                               'UniformOutput', false);
%         events.time     = cellfun(@(x)str2double(x),events.data{1,4});
%         fprintf('%d events found!\n',length(events.time));
%     else
%         fprintf('No events!\n')
%         events = [];
%     end
% 
%     % Read trajectory data
%     fprintf('Read data...');
%     
%     rat.f        = str2double(tmp{idx_tj+1});
%     rat.frame    = cellfun(@(x)str2double(x),tmp(idx_tj+5:end));
%     rat.subframe = cellfun(@(x)str2double(x),C{1,2}(idx_tj+5:end));
%     
%     treadmill. f        = rat.f;
%     treadmill. frame    = rat.frame;
%     treadmill. subframe = rat.subframe;
%  
%     % Seek treadmill markers columns
%     for j=1:length(tdmMarkers)
%        mkName = [tdmName ':' tdmMarkers{j}];
%        mkRow  = cellfun(@(x)x(idx_tj+2), C(1,1:nColTj),'UniformOutput', false);
%        idxCol = find(cellfun(@(x)strcmp(x,mkName),mkRow));
%        if isempty(idxCol)
%            error('Marker %s not found!',mkName);
%        end
%        treadmill.(sprintf('%s',tdmMarkers{j})) = cell2mat( ...
%            cellfun( @(x)str2double(x((idx_tj+5:end))), C(1,idxCol:idxCol+2), ...
%                     'UniformOutput',false));
%     end
%     
%     if ~isempty(tdmMarkers)
%     for i = 1:32
%         mkRow{i};
%     end
%     end
%     % Seek rat markers columns
%     for j=1:length(ratMarkers)
%        mkName = [ratName ':' ratMarkers{j}];
%        mkRow  = cellfun(@(x)x(idx_tj+2), C(1,1:nColTj),'UniformOutput', false);
%        idxCol = find(cellfun(@(x)strcmp(x,mkName),mkRow));
%        if isempty(idxCol)
%            error('Marker %s not found!',mkName);
%        end
%        rat.(sprintf('%s',ratMarkers{j})) = cell2mat( ...
%            cellfun( @(x)str2double(x((idx_tj+5:end))), C(1,idxCol:idxCol+2), ...
%                     'UniformOutput',false));
%     end
% 
%     fprintf('done!\n');
% 
% end
% 
