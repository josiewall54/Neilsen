classdef Run
%UNTITLED1 Summary of this class goes here
%   Detailed explanation goes here

   properties
       video;
       sts;
   end

   methods (Static)
       function run(pulseNumber, frameNumber)
        v = VideoData('mouse20090504_1_1022.avi', pulseNumber, frameNumber);    
        sts = EMGTimeSeries('VM12001.lbv',pwd,'.lbv');
        sts.nsamp1 = 1;
        sts.nsamp2 = sts.totNumSamples;
        initialize_sts_plot(sts, [9 10 11 12 13 14 15 16 17],v);
        set_labels({'9','10','11','12','13','14','15','16','17'});
        end
   end 
end

