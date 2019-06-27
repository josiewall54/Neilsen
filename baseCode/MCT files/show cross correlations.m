
[KINdat, KINtimes] = get_CHN_data(kinematicData,'binned');
[Fbincar, FIELDtimes] = get_CHN_data(fielddata,'binned CAR',KINtimes);
[Fbinraw, FIELDtimes] = get_CHN_data(fielddata,'binned raw',KINtimes);

useind = 600:(length(KINdat)-1);

win = 100;
temp = xcov(KINdat(useind,end-2),win,'coeff');
xvals = (-win:win)*.05;
plot(xvals,temp);
xlabel('lag (s)')
ylabel('coeff')

figure
temp = xcov(KINdat(useind,end-2),Fbinraw(useind,1),win,'coeff')
plot(xvals,temp);
xlabel('lag (s)')
ylabel('coeff')
title('E1 xcov between kinematics and power 0-4Hz')
 
figure
temp = xcov(KINdat(useind,end-2),Fbincar(useind,1),win,'coeff')
plot(xvals,temp);
xlabel('lag (s)')
ylabel('coeff')
title('E1 xcov between kinematics and power 4-8Hz')
 
 
%%
vec_list = 1:6:size(Fbinraw,2);
clear temp
for ii = 1:16
    temp(ii,:) = (xcov(Fbinraw(useind,vec_list(ii)),KINdat(useind,end-2),100,'coeff'));
end

xvals = (-100:100)*.05;

imagesc(xvals,1:16,temp)
xlabel('lag (s)')
ylabel('electrode')
title('E1 xcov between kinematics and power 200-300Hz')
legend