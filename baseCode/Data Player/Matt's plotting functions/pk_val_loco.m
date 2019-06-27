function [pk,val] = pk_val_loco(data,angles,window)
%function [pk,val] = pk_val_loco(data,angles,window)
%

[nsamp,ncycles] = size(data');
phases = linspace(-pi,pi,nsamp);

for i = 1:ncycles
    start = unwrap(angles(i) - window);
    stop =  unwrap(angles(i) + window);
    
    pk_indices = find_window(start,stop,phases);
    
    start = unwrap(angles(i)+pi - window);
    stop = unwrap(angles(i)+pi + window);
    
    val_indices = find_window(start,stop,phases);
    
    pk(i) = mean(data(i,pk_indices));
    val(i) = mean(data(i,val_indices));
 
%     plot(data(i,:))
%     hold on
%     plot(pk_indices,.4,'r.')
%     plot(val_indices,.4,'g.')
%     hold off
%     pause
 
end


function useind = find_window(start,stop,phases);
        
nsamp = length(phases);

[mn,ind1] = min(abs(phases - start));
[mn,ind2] = min(abs(phases - stop));

if (start < stop)  % it wraps around
    useind = max(1,ind1):min(nsamp,ind2);
else
    useind1 = 1:ind2;
    useind2 = ind1:nsamp;
    useind = [useind1 useind2];
end




            