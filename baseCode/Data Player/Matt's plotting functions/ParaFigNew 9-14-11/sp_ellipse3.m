function [Ellsumm] = sp_ellipse3(cl_vars)

cl_vars = cl_vars;
plot(cl_vars(1,:),cl_vars(2,:),'.');
hold on
axis(axis);
dat =[cos((-pi:.01:pi)); sin(-pi:.01:pi)]';
circ = dat;
C = [mean(cl_vars(1,:))/5 0; 0 mean(cl_vars(2,:))/5];
dat = C*dat';
dat = dat';
th = plot(dat(:,1),dat(:,2),'r.')
newdat = dat;
cent = [mean(cl_vars(1,:)) mean(cl_vars(2,:))];
cent = [0 0];
currang = 0;
dax1s = range(cl_vars(1,:))/100;
dax2s = range(cl_vars(2,:))/100;
dax1 = dax1s;
dax2 = dax2s;
dax1s = .5*dax1s;
dax2s = .5*dax2s;
dang = 5; 
drawnow
[x,y,button] = ginput(1);
t = gco;
t = get(t,'Parent');
x = get(t,'Children');
cutx = max(x);
f = gcf;

fprintf('left button for center\n');
fprintf('j - l rotate clockwise or counter clockwise\n');
fprintf('a - d to increase or decrease major axis\n');
fprintf('w - x to increase or decrease minor axis\n');
fprintf('i - , to change rotation step size\n');
fprintf('q - e to change major axis step size\n');
fprintf('z - c to change minor axis step size\n');
fprintf('right button to end\n');
[x,y,button] = ginput(1);
while button ~=3
 R = [cos(currang) sin(currang); -sin(currang) cos(currang)];
 if button ==1            % set the center      
    dat(:,1) = dat(:,1)-cent(1);
    dat(:,2) = dat(:,2)-cent(2);
    cent = [x y];
    newdat(:,1)  = dat(:,1) + cent(1);
    newdat(:,2)  = dat(:,2) + cent(2);
 end
 if button == 'a'+0       %major increase
   C(1,1) = C(1,1)+dax1;
   C = abs(C);
   newdat = R*(C*circ');
   newdat=newdat'; 
   newdat(:,1)  = newdat(:,1) + cent(1);
   newdat(:,2)  = newdat(:,2) + cent(2);
 end
 if button == 'd'+0       %major decrease
   C(1,1) = C(1,1)-dax1;
   C = abs(C);
   newdat = R*(C*circ');
   newdat=newdat'; 
   newdat(:,1)  = newdat(:,1) + cent(1);
   newdat(:,2)  = newdat(:,2) + cent(2);
 end
 if button == 'w'+0	  %minor increase
   C(2,2) = C(2,2)+dax2;
   C = abs(C);
   newdat = R*(C*circ');
   newdat=newdat'; 
   newdat(:,1)  = newdat(:,1) + cent(1);
   newdat(:,2)  = newdat(:,2) + cent(2);
 end
 if button == 'x'+0       %minor decrease
   C(2,2) = C(2,2)-dax2;
   C = abs(C);
   newdat = R*(C*circ');
   newdat=newdat'; 
   newdat(:,1)  = newdat(:,1) + cent(1);
   newdat(:,2)  = newdat(:,2) + cent(2);
 end
 if button == 'l'+0       % rotate clockwise
    newdat(:,1)  = dat(:,1) - cent(1);
    newdat(:,2)  = dat(:,2) - cent(2);
    newdat = rotate2(newdat(:,1:2)',5)';
    newdat(:,1)  = newdat(:,1) + cent(1);
    newdat(:,2)  = newdat(:,2) + cent(2);
    currang = currang +dang*pi/180;
 end 
 if button == 'j'+0       % rotate ccw
    newdat(:,1)  = dat(:,1) - cent(1);
    newdat(:,2)  = dat(:,2) - cent(2);
    newdat = rotate2(newdat(:,1:2)',-5)';
    newdat(:,1)  = newdat(:,1) + cent(1);
    newdat(:,2)  = newdat(:,2) + cent(2);
    currang = currang-dang*pi/180;
 end 
 if button == 'i'+0       % increase angle step
    dang = dang+1;
 end
 if button == ','+0       % decrease angle step
    dang = dang-1;
    if dang<0
      dang =1;
    end
 end
 if button == 'e'+0       % increase axis step
    dax1 = dax1+dax1s;
 end
 if button == 'q'+0       % decrease axis step
    dax1 = dax1-dax1s;
    if dax1<0
      dax1 = dax1s;
    end
 end
 if button == 'c'+0       % increase axis step
    dax2 = dax2+dax2s;
 end
 if button == 'z'+0       % decrease axis step
    dax2 = dax2-dax2s;
    if dax2<0
      dax2 =dax2s;
    end
 end
 
 set(th,'Ydata',[],'Xdata',[]);   % get rid of the last ellipse
 th = plot(newdat(:,1),newdat(:,2),'r.');  
 dat=newdat;
 [x,y,button] = ginput(1);
end

R = [cos(currang) sin(currang); -sin(currang) cos(currang)];

Ellsumm = [cent R(1:4) C(1:4)];


