function spdat = spfiginit()
%function spfiginit()
%  Function to initialize spike figure.  Creates and initializes the
%  the data structure in the spike figure.

spdat = 0;
spdat.fname = '';
spdat.data = [];
spdat.nchan = 0;
spdat.nsamp = 80;
spdat.freq = 0;
spdat.currchan = 0;
spdat.plotdens = .01;
spdat.clusind = 0;
spdat.pcomps = 0;

% set(gcf,'UserData',spdat);


