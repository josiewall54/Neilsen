%function [LFPfilesPDs]=PDs_from_spikes_LFPs(pathname,allroots,LFPs,fbandst,fbanden,startword,rewardword,shiftstart,degres,timeaft,pvallim)
clear;close all; clc;

pathnameraw='\\165.124.111.234\data\Miller\Pedro_4C2\S1 Array\raw\';
pathname='\\165.124.111.234\data\Miller\Pedro_4C2\S1 Array\processed\';

allroots={'Pedro_2011-05-04_RW_001'};

bdf=get_cerebus_data([pathnameraw,char(allroots),'.nev'],'verbose');
save([pathname,char(allroots),'.mat'],'bdf');
LFPs=1:96;

fbandst=[10,70,130,200,300];
fbanden=[50,110,190,290,390];

% fbandst=[300];
% fbanden=[390];

startword=18;
rewardword=32;
shiftstart=0;
degres=30;
timeaft=0.2;
pvallim=0.05;




% this fuction generates a cell array called allfilesPDs and it uses
% bootstrap.m
%-each column corresponds to a file designated in the allroots arguments.
%-for each file, first row contains all the PDs (preferred direction) and all the informations about each unit :
%--- 'chanel','unit','lower confidence interval','mean PD','upper...
%---confidence interval','mean magnitude of the PD','spik count','file length','spik...
%---count/data lenght','stdISI','mean ISI','CV'(coefficient of variation)

%-seconfd row contains the name of the file
%-third row contains the recorded date time of the file

%the inputs:
%-pathname: designtte the path to the folder containing all the mat files to be
%analysed.pathname should end with \ as in ' \';
%-allroots: contains names of the mat files to be analysed, don't
%add '.mat'; allroots should be entrered between the curly brackets{' ';' ';' '...};
%LFPs: put the LFP channels you want to be analized:LFPs=(1:96);
%fbandst=[10,70,130]; starts  of each frequency band
%fbanden=[50,110,190];ends  of each frequency band

%-rewardword= word corresponding to the rewrard;
%-startword= word corresponding to the start( the program will find the starts that corresponded
%to a real reward and discard the starts that ended with a failure).
%-shiftstart in seconds , shiffts the start (avoids noise after the
%start of a trial).CAREFULL shiftstart should be less than the minimum the
%program will ask you to input a shiftstart if it is superior to this
%minimums trial duration.
%-duration of a trial.
%-degres= degree resolution in degree not in radian: all PDs in that degre
%wil be compiled together: if degres is 30, PDs between 0-30 degree will be
%comiled togheter befor going to the bootstrap.
%-timeaft=time of the window form where the directions vectors would be
%calculed.
%-pvallim= for example it could be 0.1,0.05,0.01...corresponding  to a 10%,
%5% or 1% allows us to get the lower limit and upper limit pf the PD
%confidence interval.
% pathname='\\165.124.111.234\data\Miller\Pedro_4C2\S1 Array\Processed\';
% allroots={'Pedro_S1_040-s','Pedro_S1_042-s','Pedro_S1_043-s','Pedro_S1_044-s','Pedro_S1_046-s','Pedro_S1_047-s'};

allfilesPDs=cell(3,length(allroots));

for nr=1:length(allroots)    
    root=char(allroots(:,nr));
    data=LoadDataStruct([pathname,root,'.mat']);
    disp('data loaded');
    degres=degres * pi / 180;
    os=-pi:degres:pi;
    direc=os;
    direc(1)=[];
    
 
   
    
%     dd=[];
%     dd=[dd data.units.id];
%     chan=dd(1:2:end-1);
%     units=dd(2:2:end);
%     chanunit(:,1)=dd(1:2:end-1)';
%     chanunit(:,2)=dd(2:2:end)';
    
%     for i=1:length(chanunit)
%         isi=[];
%         unicount(i)=length(data.units(1,i).ts);
%         lendata(i)= data.pos(end,1);
%         for j=1 :  unicount(i)-1;
%             isi(j)=data.units(1,i).ts(j+1)-data.units(1,i).ts(j);
%         end
%         meanisi(i)=mean(isi);
%         stdisi(i)=std(isi);
%         cvisi(i)=stdisi(i)/meanisi(i);
%     end;

    
%     postimes=(data.pos(:,1)*1000);
    
    
    
    xposall=data.pos(:,2);
    yposall=data.pos(:,3);
    
%     psr= 1/(postimes(2)- postimes(1))*1000;
    
    
%     if psr<1000
%         postim=(postimes(1):1:(postimes(end)))';
%         xposall=interp1(postimes,data.pos(:,2),postim,'nearest');
%         yposall=interp1(postimes,data.pos(:,3),postim,'nearest');
%         postimes=postim;
%     end
    
    cuesall= data.words(:,1);
    words=data.words(:,2);
    startI=cuesall(find(words==startword));
    ends=cuesall(find(words==rewardword));
    while (startI(1)<=1)
        startI(1)=[];
    end;
    while (ends(1)<startI(1))
        ends(1)=[];
    end;
    while (startI(end)>ends(end))
        startI(end)=[];
    end; 
   
for i=1 :length(ends)
    inend=(find(startI<ends(i)));
    starts(i)=startI(inend(end));
end
    starts=starts';
    
    mintrialtime=min(ends-starts);

    
while abs(shiftstart)> mintrialtime
    beep
  shiftstart= input(['shiftstart should be less than ',num2str(mintrialtime),'; shiftstart = ']);
end
    
    starts=starts+abs(shiftstart);
   
    
    while ends(end)>data.pos(end,1)-timeaft
        
        ends(end)=[]
         starts(end)=[]
         disp(['removing  trial starteing at',int2str( starts(end)) ]);
    end
    
    
        td=sum(ceil((ends-starts)/timeaft));
    
    moves=[];
    trials=[];
    direction=zeros(td,1);
    modul=[];
    yud=0;

    for i=1: length(starts)
        moves=[moves; cuesall(find(ends(i)> cuesall & cuesall > starts(i)))];
        
    end;
    
     disp('Starting getting direction for each trial');tic
  %  postimes=uint64(postimes);
    
    for i=1: length(starts)
        %% x and y positions for each cues in each trial
        rt=starts(i);
        while rt<ends(i)+timeaft

 xpos=data.pos(find(data.pos(:,1)>=rt,1),2);
 xpos2=data.pos(find(data.pos(:,1)>=rt+timeaft,1),2);

 ypos=data.pos(find(data.pos(:,1)>=rt,1),3);
 ypos2=data.pos(find(data.pos(:,1)>=rt+timeaft,1),3);
            %% vector calculate
            xposvect=xpos2-xpos;
            yposvect=ypos2-ypos;
            yud=yud+1;
            direction(yud)= atan2(yposvect,xposvect);

               chi=0;
            for j=1:length(LFPs)
                  chi=chi+1;
                LFP=(data.raw.analog.data{1,LFPs(j)});
                LFPrate=data.raw.analog.adfreq(1,LFPs(j));
                LFPsample=LFP(rt*LFPrate:rt*LFPrate+timeaft*LFPrate);
                powlfp=zeros(1,length(LFPsample));
                lfp=zeros(1,length(LFPsample));
                lfp=fft(LFPsample,[],2)';
                powlfp=powlfp+lfp.*conj(lfp);
                f=linspace(0,LFPrate/2,length(LFPsample)/2+1);
                g=find(f<fbanden(end)+10);
                bmax=g(end);
                gat=(powlfp(1,2:bmax));
                fsam=f(1,2:bmax);
                 for k=1:length(fbandst)
              fst=find(fsam==fbandst(k));fend=find(fsam==fbanden(k)); 
              LFPall{1,k}(yud,chi)=max(gat(fst:fend));  
                 end
            end   
             disp(['LFP ',int2str(j),' done']);
            rt=rt+timeaft;
        end
    end
     disp('End getting direction for each trial');toc
for r=1:size(LFPs,2)
    for k=1:length(fbandst)
        chLFP=LFPall{1,k}(:,r);
        
        for i=1:length(os)-1
            LFP_counts{r,k}{i}=chLFP(find(os(i) < direction & direction < os(i+1)));
        end
    end
    end;
    %% bootstrapping then calculate the circular mean and the CI
    pvallim=pvallim*100;
    lowCI=pvallim/2;
    upCI=100-pvallim/2;

  for k=1:length(fbandst)
      disp(['band',int2str(k),'/',int2str(length(fbandst))]);toc
    for x = 1:size(LFPs,2)
     
             disp(['LFP',int2str(x),'/',int2str(size(LFPs,2))]);toc
        bootstrapPDS{x,k} = bootstrap(@vector_sum_pd,LFP_counts{x,k}, 'all', 1000);
        ss=bootstrapPDS{x,k}(:,1)-pi;
        PDMatrix{1,k}(x,:)=cprctile(ss,[lowCI 50 upCI]);
    end
  end   
    
    %% get the mean magnitudes and plot PD as a polar
    
    for k=1:length(fbandst)
        
    for x = 1:size(LFPs,2)
        
   
        PDMatrix{1,k}(x,5)= LFPs(x);  
        PDMatrix{1,k}(x,4) =mean(bootstrapPDS{x,k}(:,2));
    end;
    end   
  LFPfilesPDs{1,nr}= PDMatrix;
    LFPfilesPDs{2,nr}= allroots(nr);

    LFPfilesPDs{3,nr}=data.meta.datetime;
        waitbar(nr/length(allroots))
    clearvars -except allroots rn nr LFPfilesPDs  h pathname rewardword startword shiftstart degres timeaft pvallim
end
 toc
save(['Y:\user_folders\Boubker\PDs\',char(LFPfilesPDs{2,1})],'LFPfilesPDs');
%close h
% end

quit