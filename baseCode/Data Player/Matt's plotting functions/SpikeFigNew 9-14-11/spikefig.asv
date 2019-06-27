function spikefig(flag,varargin)

col = ['b' 'r' 'm' 'c'];
parent = get(gco,'Parent');
spdat = get(parent,'UserData');   %  retrieve the data structure

switch flag
    case 'data'  % they've sent in the data directly
        spdat = spfiginit;
        temp = varargin{1};
        spdat.sp_times = varargin{2};
        spdat.data = temp(:);
        spdat.nchan = size(spdat.data,3);
        spdat.nsamp = size(temp,1);
        spdat.nspikes = size(temp,2);
        %     spdat.nspikes = floor(size(spdat.data,1)/spdat.nsamp);
        %    spdat.data = spdat.data(1:(spdat.nsamp*spdat.nspikes),1:spdat.nchan);
        spdat.currchan = 1;
        spdat.para = spfig_parainit(spdat.nchan,spdat.nsamp);
        hndl = get_spfig_obj('ChanButton');
        set(hndl,'String','1');
        spfig_replot(spdat);
    case 'filename'
        spdat = spfiginit;
        fname = get(gco,'String');
        spdat.fname = fname;
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
        str = ['spdat.data =' sfname];
        %    eval(str);
        temp = aps';
        spdat.data = temp(:);
        spdat.nchan = size(spdat.data,3);
        spdat.nsamp = size(aps,2);
        spdat.nspikes = size(aps,1);
        %     spdat.nspikes = floor(size(spdat.data,1)/spdat.nsamp);
        %    spdat.data = spdat.data(1:(spdat.nsamp*spdat.nspikes),1:spdat.nchan);
        spdat.currchan = 1;
        spdat.para = spfig_parainit(spdat.nchan,spdat.nsamp);
        hndl = get_spfig_obj('ChanButton');
        set(hndl,'String','1');
        spfig_replot(spdat);
case  'showchan'
   spdat.currchan = spdat.currchan+1;
   if spdat.currchan >spdat.nchan
      spdat.currchan = 1;
   end
   set(gco,'String',num2str(spdat.currchan));
   spfig_replot(spdat);  
case 'plotdens'
   temp = get(gco,'String');
   spdat.plotdens = str2num(temp);
  spfig_replot(spdat);  
case 'ParaMenu'
   paraind = get(gco,'Value');   % the index to the chosen parameter
   ch = spdat.para(paraind,3);   % plot the aps relevant to parameter
   spdat.currchan = ch;
   spfig_replot(spdat);
   p1 = spdat.para(paraind,4);   % get the values for the control
   p2 = spdat.para(paraind,5);   % parameters
   hndl = get_spfig_obj('P1Button');
   set(hndl,'Value',p1);
   hndl = get_spfig_obj('P2Button');
   set(hndl,'Value',p2);   
case 'NsampEdit'
   temp = get(gco,'String');
   spdat.nsamp = str2num(temp);
case 'AllButton'
   disp('sorry - haven''t figured this one out yet');
   return; 
   val = get(gco,'String');
   if val == 'ShowAll';
      n = spdat.nchan;
      for i = 1:n
         subplot(n,1,i);
         spfig_replot(spdat);  
      end
      set(gco,'String','ShowOne');
   else
      subplot(1,1,1);
      spfig_replot(spdat);  
      set(gco,'String','ShowAll');
   end
case 'RmBaseButton'
   val = get(gco,'String');
   if strcmp(val,'RemoveBase')
      for i = 1:spdat.nchan
         temp = zeros(spdat.nsamp,spdat.nspikes);
         junk = spdat.data(:,i);
         temp(:) = junk(:);
         base = mean(temp(1:end,:));
         for j = 1:spdat.nsamp
            temp(j,:) = temp(j,:)-base;
         end
         spdat.data(:,i) = temp(:);
      end
      spfig_replot(spdat);  
%      set(gco,'String','BaseRemoved');
   end
case 'AddParaButton'
   hndl = get_spfig_obj('ParaMenu');
   itemn = get(hndl,'Value');
   spdat.para(itemn,1) = 1;
   parastr = get(hndl,'String');
   str = '';
   for i = 1:size(spdat.para(:,1));
      if spdat.para(i,1)
         str = char(str,parastr(i,:));
      end
   end
   str = str(2:end,:);
   hndl = get_spfig_obj('ParaBox');
   set(hndl,'String',str);
case 'DelParaButton'
   hndl = get_spfig_obj('ParaMenu');
   itemn = get(hndl,'Value');
   spdat.para(itemn,1) = 0;
   parastr = get(hndl,'String');
   str = '';
   for i = 1:size(spdat.para(:,1));
      if spdat.para(i,1)
         str = char(str,parastr(i,:));
      end
   end
   str = str(2:end,:);
   hndl = get_spfig_obj('ParaBox');
   set(hndl,'String',str);
case 'ParaFnameEdit'
   fname = get(gco,'String');
   [para,parastr] = xtract_para(spdat.data,spdat.para,spdat.nspikes,spdat.nsamp);
   str = ['save ' fname ' para parastr'];
   eval(str);
case {'P1Button','P2Button'}
   pn = str2num(flag(2));
   [val,y] = ginput(1);
   hndl = get_spfig_obj('ParaMenu');
   itemn = get(hndl,'Value');
   if spdat.para(itemn,2) == 7   % it's a spike width 
      val = y;
   end
   spdat.para = upcurrpara(spdat.para,itemn,pn,round(val));
   spfig_replot(spdat);
case 'ClusFileEdit'
   fname = get(gco,'String');
   if (fopen(fname,'r') == -1)
      fprintf('Error reading file');
      return
   end
   str = ['load ' fname];
   eval(str);
   spdat.clusind = clusind'; % assume that clusind is in the file
case 'ShowClusButton'
   figure
   lst = unique(spdat.clusind);
   nclus = length(lst(lst>0));     % negative numbers mean ignore
   nclus = max(spdat.clusind);    % assume that it starts from 1
   temp = zeros(spdat.nsamp,spdat.nspikes);   
   for i = 1:spdat.nchan
      junk = spdat.data(:,i);
      temp(:) = junk(:);  % copy all data
      miny = min(temp(:)); maxy = max(temp(:));      
      for j = 1:nclus
         fignum = (i-1)*nclus+j;
         subplot(spdat.nchan,nclus,fignum)
         ind = find(spdat.clusind == j);
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
   figure(parent);
case 'SavelistEdit'
   fname = get(gco,'String');
   paralist = spdat.para;
   str = ['save ' fname ' paralist'];
   eval(str);
case 'open_parafig_button'
   [para,parastr] = xtract_para(spdat.data,spdat.para,spdat.nspikes,spdat.nsamp);
   parafig('initialize_parafig',para,parastr, spdat);  
   return  % terminate without updating the UserData
end
set(gcf,'UserData',spdat);
