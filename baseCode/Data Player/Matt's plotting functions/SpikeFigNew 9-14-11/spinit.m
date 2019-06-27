function spinit()
%function spinit()
%  Function to initialize spike figure.  Creates and initializes the
%  the data structure in the spike figure.

spdat = 0;
spdat.fname = '';
spdat.data = [];
spdat.nchan = 0;
spdat.nsamp = 80;
spdat.freq = 0;
spdat.currchan = 0;
spdat.plotdens = 100;

set(gcf,'UserData',spdat);


