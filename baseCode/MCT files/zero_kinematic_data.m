function kin_data = zero_kinematic_data(kin_data, params)

viconScalingFactor = params.viconScalingFactor;
referenceMarker = params.referenceMarker;
freq = params.ViconFreq;

% Make this a function. There must be 2 separate functions to process Kin & EMG
%an_data.processedKinData = processKinematicData_funct (an_data);

% kin_data = an_data.kinematicData;
rawKin = []; kinLabels = [];

for i = 1:length(kin_data.names)   
    kinLabels = [ kinLabels {[kin_data.names{i} '_x']} {[kin_data.names{i} '_y']} {[kin_data.names{i} '_z']} ];
    rawKin = [rawKin kin_data.x(:,i) kin_data.y(:,i) kin_data.z(:,i)];
end
% Convert to mm:
rawKin = rawKin / viconScalingFactor;
kin_data.rawKinMatrix = rawKin;
kin_data.KinMatrixLabels = kinLabels;
clear kinLabels; clear rawKin;

% Reference every marker to the most stable one to disregard threadmill-caused movement. TIP: hip_middle
% refMarkerField = ['rawKinMatrix_ref_' referenceMarker];
rawKin = [];
if ~isempty (referenceMarker)
    
    posRefMarker = strmatch(referenceMarker, kin_data.names); % Find marker in array;
    refX = kin_data.x(:, posRefMarker); 
    refY = kin_data.y(:, posRefMarker); 
    refZ = kin_data.z(:, posRefMarker); 
    
    for i = 1:length(kin_data.names)   
        rawKin = [rawKin kin_data.x(:,i)-refX kin_data.y(:,i)-refY kin_data.z(:,i)-refZ];
    end
    kin_data.refKinMatrix = rawKin;
end

kin_data.timeframe = 0:(1/freq):(length(kin_data.x)*(1/freq) - (1/freq));

