function spfig_replot(spdat)
%function spfig_replot(spdat)
%  Function to replot the current window after a change has occurred
%  This is likely to be buggy for a little while as I haven't really
%  figured out all this windows stuff yet.

col = ['b' 'r' 'm' 'c'];
% first replot the data
hold off
temp = zeros(spdat.nsamp,spdat.nspikes);
junk = spdat.data(:,spdat.currchan);
temp(:) = junk(:);  % copy the relevant data
nshow = spdat.nspikes*spdat.plotdens/100;
plot(temp(:,1:round(spdat.nspikes/nshow):end),col(spdat.currchan));
hold on

% now plot the current control parameters for the parameter extract
hndl = get_spfig_obj('ParaMenu');
paran = get(hndl,'Value');   % find the current parameter
if spdat.currchan == spdat.para(paran,3) % it's not the current
    plotpara(spdat.para(paran,:));    % channel, don't show it
end
