function para = modelcellfiring(mns,angmag,start)

n = length(mns);
global ANGMAG MNS;
ANGMAG = angmag;
MNS = mns;

options = foptions;
options(14) = 9999;
%start = [10 unifrnd(0.1,1,7,1)];
para = leastsq('modelcellfiring_res',start,options);

