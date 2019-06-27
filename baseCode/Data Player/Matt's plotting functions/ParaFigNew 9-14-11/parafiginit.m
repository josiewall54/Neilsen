function paradat = parafiginit(varargin)
%function parafiginit()
%  Function to initialize parameters figure. Creates and initializes
%  the data structure in the parameters figure.

paradat = 0;
paradat.fname = '';
paradat.data = [];
paradat.npara = 0;
paradat.nspikes = 0;
paradat.plotdens = 100;
paradat.clusind =0;
paradat.plotpara = [0 0 0];
paradat.nclus = 0;
paradat.currclus = 0;
paradat.ts = 0;
paradat.clusters= zeros(1,20)-9999;
paradat.add = 0;

if nargin > 1  % they sent in the parameter values and the strings already 
    para = varargin{1};
    parastr = varargin{2};
    paradat.data = para;     % these are assumed to be in the file
    paradat.parastr = parastr;
    paradat.npara = size(paradat.data,2);
    paradat.nspikes = size(paradat.data,1);
    paradat.clusind = ones(1,paradat.nspikes);
    hndl = get_parafig_obj('XParaMenu');
    set(hndl,'String',parastr);
    hndl = get_parafig_obj('YParaMenu');
    set(hndl,'String',parastr);
    hndl = get_parafig_obj('ZParaMenu');
    set(hndl,'String',parastr);
    paradat.clusters(1,1) = 1;
    for i = 1:paradat.npara
        paradat.clusters(1,2*i) = min(para(:,i)) - .1;
        paradat.clusters(1,2*i+1) = max(para(:,i)) + .1;
    end
    paradat.clusind = ones(paradat.nspikes,1);
    paradat.nclus = 1;
    paradat.currclus = 1;
end
% set(gcf,'UserData',paradat);

if nargin > 2 % they also sent in the AP waveforms
    paradat.spdat = varargin{3};
end


