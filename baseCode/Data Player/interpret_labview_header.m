function info_out = interpret_labview_header(info,varargin);
%function info_out = interpret_labview_header(info,varargin);
%   Function to interpret the information in a header file as those saved
%   by labview.  Returns a structure INFO_OUT with fields describing the
%   information in the original header

if nargin == 2
   headertype = varargin{1};
else 
    headertype = 'general';  % default to a type where they're all strings
end

switch headertype
    case 'general'
        info_out = interpret_general_header(info);
    otherwise
        info_out = info;
end        


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Local functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function info_out = interpret_general_header(info)

fields = fieldnames(info);

for i = 1:length(fields)
    val = info.(fields{i});
    switch fields{i}
        case 'Channels_to_be_recorded'
            channames = split_string(val);
            info_out.nchan = length(channames);
            info_out.channames = char(channames);
        case 'Sampling_Rate'
            info_out.samprate = str2num(val);
        case 'Total_acquired'
            info_out.total_to_be_acquired = str2num(val);
        case 'Counter_delay'
            info_out.initial_delay = str2num(val);
        case 'Channel_Physical_Names'
            channames = split_string(val);
            info_out.nchan = length(channames);
            info_out.physical_channames = char(channames);
        case 'Channel_Max'
            info_out.chan_max = str2num(val);
        case 'Channel_Min'
            info_out.chan_min = str2num(val);
        case 'Hip_X__Y__Z'
            info_out.hippos = str2num(val);
        case 'Link_1'
            info_out.link1 = str2num(val);
        case 'Link_2'
            info_out.link2 = str2num(val);
        case 'Link_3'
            info_out.link3 = str2num(val);
        case 'FT_Attach_Point'
            info_out.FT_attach_point = str2num(val);
        case 'X_Y_Z_Positions'
            info_out.positions = str2num(val);
        case 'Array'
            temp = str2num(val);
            info_out.positions2 = reshape(temp,3,length(temp)/3);
        case 'Position_Input'
            info_out.position_input_mode = val;
        otherwise
            info_out.(fields{i}) = val;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function arr = split_string(val)

rem = val;  n = 0;
while ~isempty(rem)
    [val,rem] = strtok(rem);
    n = n + 1;
    arr{n} = val;
end
n = n -1;
arr = arr(1:n);
