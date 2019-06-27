function varargout = parafig(flag, varargin)

col = ['b' 'r' 'm' 'c'];
parent = get(gco,'Parent');
paradat = get(parent,'UserData');   %  retrieve the data structure

switch flag
    case 'initialize' % this is if the figure is already there??
        if nargin < 2  % they didn't send it the data
            disp('you didn''t send in a set of data')
        end
        paradat = parafiginit(varargin{:});
    case 'initialize_parafig'  % this one creates the figure as well
        fignum = open('parafig_new.fig');
        figure(fignum)
        if nargin < 2  % they didn't send it the data
            disp('you didn''t send in a set of data')
        end
        paradat = parafiginit(varargin{:});
    case 'filename'
%         parafiginit;
        fname = get(gco,'String');
        paradat.fname = fname;
        if (fopen(fname,'r') == -1)
            fprintf('Error reading file');
            return
        end
        str = ['load ' fname];
        eval(str);
        paradat = parafig('initialize',para,parastr);  % these come from the filename
        paradat.fname = fname;

        %         paradat.data = para;     % these are assumed to be in the file
%         paradat.parastr = parastr;
%         paradat.npara = size(paradat.data,2);
%         paradat.nspikes = size(paradat.data,1);
%         paradat.clusind = ones(1,paradat.nspikes);
%         hndl = get_parafig_obj('XParaMenu');
%         set(hndl,'String',parastr);
%         hndl = get_parafig_obj('YParaMenu');
%         set(hndl,'String',parastr);
%         hndl = get_parafig_obj('ZParaMenu');
%         set(hndl,'String',parastr);
%         paradat.clusters(1,1) = 1;
%         for i = 1:paradat.npara
%             paradat.clusters(1,2*i) = min(para(:,i)) - .1;
%             paradat.clusters(1,2*i+1) = max(para(:,i)) + .1;
%         end
%         paradat.clusind = ones(paradat.nspikes,1);
%         paradat.nclus = 1;
%         paradat.currclus = 1;
    case 'plotdens'
        temp = get(gco,'String');
        paradat.plotdens = str2num(temp);
        parafig_replot(paradat);
    case 'PlotXYButton'
        hndl = get_parafig_obj('XParaMenu');
        xind = get(hndl,'Value');
        hndl = get_parafig_obj('YParaMenu');
        yind = get(hndl,'Value');
        paradat.plotpara = [xind yind 0];
        parafig_replot(paradat);
    case 'PlotXYZButton'
        hndl = get_parafig_obj('XParaMenu');
        xind = get(hndl,'Value');
        hndl = get_parafig_obj('YParaMenu');
        yind = get(hndl,'Value');
        hndl = get_parafig_obj('ZParaMenu');
        zind = get(hndl,'Value');
        paradat.plotpara = [xind yind zind];
        parafig_replot(paradat);
    case 'AzSlider'
        a= axis;
        if paradat.plotpara(3)
            az =get(gco,'Value');
            hndl = get_parafig_obj('ElSlider');
            el = get(hndl,'Value');
            view(az,el);
        end
        axis(a);
    case 'ElSlider'
        a = axis;
        if paradat.plotpara(3)
            el =get(gco,'Value');
            hndl = get_parafig_obj('AzSlider');
            az = get(hndl,'Value');
            view(az,el);
        end
        axis(a);
    case 'NewBoxButton'  % make a new box cluster
        paradat.nclus = paradat.nclus+1;
        paradat.currclus = paradat.nclus;
        hndl = get_parafig_obj('ClusNumButton');
        set(hndl,'String',num2str(paradat.currclus));
        paradat = parafig_newclus(paradat);
        paradat = parafig_divide(paradat);
        parafig_replot(paradat);
    case 'NewEllButton'  % make a new ellipse cluster
        paradat.nclus = paradat.nclus+1;
        paradat.currclus = paradat.nclus;
        hndl = get_parafig_obj('ClusNumButton');
        set(hndl,'String',num2str(paradat.currclus));
        paradat = parafig_newell(paradat);
        paradat = parafig_divide(paradat);
        parafig_replot(paradat);
    case 'ClusNumButton'
        paradat.currclus = paradat.currclus+1;
        if paradat.currclus > paradat.nclus
            paradat.currclus = 1;
        end
        set(gco,'String',num2str(paradat.currclus));
        parafig_replot(paradat);
    case 'ClusFreeButton'
        nclus = paradat.nclus;
        curr = paradat.currclus;
        if curr ~= 1  % don't delete the first cluster
            n = 1;
            for i = 1:nclus   % collapse the stack of clusters
                if i ~= curr
                    paradat.clusters(n,:) = paradat.clusters(i,:);
                    n = n+1;
                end
            end
            paradat.cluster(nclus,:) = 0;
            paradat.nclus = paradat.nclus-1;
            paradat.currclus = paradat.currclus-1;
            paradat = parafig_divide(paradat);
            parafig_replot(paradat);
            hndl = get_parafig_obj('ClusNumButton');
            set(hndl,'String',num2str(paradat.currclus));
        end
    case {'TopEditButton','LeftEditButton','RightEditButton','BottomEditButton'}
        curr = paradat.currclus;
        if paradat.clusters(curr,1) == 1  % only do this if it's a box
            hndl = get_parafig_obj('XParaMenu');
            xind = get(hndl,'Value');
            hndl = get_parafig_obj('YParaMenu');
            yind = get(hndl,'Value');
            [x,y] = ginput(1);
            if curr ~= 1
                switch(flag(1))
                    case 'T'  % change the max on the y para cluster value
                        paradat.clusters(curr,yind*2+1) = y;
                    case 'L'
                        paradat.clusters(curr,xind*2) = x;
                    case 'R'
                        paradat.clusters(curr,xind*2+1) = x;
                    case 'B'
                        paradat.clusters(curr,yind*2) = y;
                end
                paradat = parafig_divide(paradat);
                parafig_replot(paradat);
            end
        else
            disp('editing borders is only valid for boxes right now')
        end
    case 'SaveFnameEdit'       % saves the cluster indices, the timestamps, and the cluster definitions
        fname = get(gco,'String');
        clusind = paradat.clusind;
        clusters = paradat.clusters;
        ts = paradat.ts;
        str = ['save ' fname ' clusind clusters ts'];
        eval(str);
    case 'PrevFnameEdit'
        fname = get(gco,'String');
        paradat.fname = fname;
        if (fopen(fname,'r') == -1)
            fprintf('Error reading file');
            return
        end
        str = ['load ' fname];
        eval(str);
        paradat.clusters = clusters;
        paradat.nclus = size(clusters,1);
        paradat.clusind = clusind;
        %   paradat = parafig_divide(paradat);
        parafig_replot(paradat);
    case 'NKmnsEdit'   % if they edit it, do it
        nclus = str2num(get(gco,'String'));
        paradat.nclus = nclus;
        paradat = para_kmns(paradat);
        parafig_replot(paradat);
    case 'TSFileEdit'
        fname = get(gco,'String');
        if (fopen(fname,'r') == -1)
            fprintf('Error reading file');
            return
        end
        str = ['load ' fname];
        eval(str);
        sfname = strtok(fname(end:-1:1),'\');
        sfname = sfname(end:-1:1);
        sfname = strtok(sfname,'.');
        if length(str2num(sfname(1)))
            sfname = ['X' sfname];
        end
        str = ['paradat.ts =' sfname];
        eval(str);
    case 'ISIButton'
        curr = paradat.currclus;
        paradat.ts = paradat.spdat.sp_times;  % get the times from the spdat structure
        if paradat.ts == 0
            disp('you need to enter a timestamp file first')
            return
        end
        
        nclus = max(paradat.clusind);    % assume that it starts from 1        
        str = char('blue','red','magenta','cyan','green','yellow','black');

        figure
        for ii = 1:nclus
            subplot(1,nclus,ii);
            times = paradat.ts(paradat.clusind == ii);
            if length(times) < 2
                disp('need at least 2 spikes')
                times = [0 1000 2000];
                %                 return
            end
            times = times;  % assume it's in ms
            divs = 0:1:50;   % set .5ms bins
            dt = diff(times);
            for i = 1:(length(divs)-1)
                ind = find((dt> divs(i)) & (dt< divs(i+1)));
                n(i) = length(ind);
            end
            bar(divs(1:(end-1))+.5,n)
            tstr = [str(ii,:)];
            title(tstr);
%             title(sum(n(1))/length(dt))
            xlabel('ISI (ms)')
            ylabel('count')
        end
    case 'ShowAPsButton'
        figure
        spdat = paradat.spdat;
        lst = unique(paradat.clusind);
        nclus = length(lst(lst>0));     % negative numbers mean ignore
        nclus = max(paradat.clusind);    % assume that it starts from 1
        temp = zeros(spdat.nsamp,spdat.nspikes);
        for i = 1:spdat.nchan
            junk = spdat.data(:,i);
            temp(:) = junk(:);  % copy all data
            miny = min(temp(:)); maxy = max(temp(:));
            for j = 1:nclus
                fignum = (i-1)*nclus+j;
                subplot(spdat.nchan,nclus,fignum)
                ind = find(paradat.clusind == j);
                if length(ind) > 0
                    nsp = length(ind);
                    nshow = nsp*spdat.plotdens/100;
                    plot(temp(:,ind(1:round(nsp/nshow):end)),col(i));
                    axis([0 spdat.nsamp miny maxy]);
                end
            end
        end
        col = char('b.','r.','m.','c.','g.','y.','k.','bx','rx','mx','cx','gx','yx','kx');
        
        str = char('blue','red','magenta','cyan','green','yellow','black');
        for j= 1:nclus
            subplot(spdat.nchan,nclus,j);
            tstr = [str(j,:)];
            title(tstr);
        end
%         figure(parent);
    case 'AxesButtonDown'
        currPt = get(gca,'CurrentPoint');
        xval = currPt(1,1);
        yval = currPt(1,2);
        xind = paradat.plotpara(1);
        yind = paradat.plotpara(2);
        dat = paradat.data;
        Xdata = dat(:,xind);
        Ydata = dat(:,yind);
        dist = (xval-Xdata).^2 + (yval - Ydata).^2;
        [mn,ind] = min(dist);
        spdat = paradat.spdat;
        
        temp = zeros(spdat.nsamp,spdat.nspikes);
        for i = 1:spdat.nchan
            junk = spdat.data(:,i);
            temp(:) = junk(:);  % copy all data
            miny = min(temp(:)); maxy = max(temp(:));
            if length(ind) > 0
                nsp = length(ind);
                nshow = nsp*spdat.plotdens/100;
                figure
                plot(temp(:,ind(1:round(nsp/nshow):end)));
                axis([0 spdat.nsamp miny maxy]);
            end
        end
    case 'SaveButton'        
        [fname, pathname] = uiputfile({[]}, 'Choose file name for saving spiking results');
        waveforms = zeros(paradat.spdat.nsamp,paradat.spdat.nspikes);
        waveforms(:) = paradat.spdat.data(:);
        sp_times = paradat.spdat.sp_times;
        clusters = paradat.clusind;        
        save_paradat = paradat;
        save_paradat.sp_data.data = 0; % to save space get rid of the waveform data
        save(strcat(pathname,fname),'waveforms','sp_times','clusters','save_paradat');   
        msgbox(['Done saving results to ' strcat(pathname,fname)]); 
end

set(gcf,'UserData',paradat);

