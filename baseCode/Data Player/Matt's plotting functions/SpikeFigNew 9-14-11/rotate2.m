function newdat = rotate2(dat,angle)
q = -angle*pi/180;
R = [cos(q) -sin(q); sin(q) cos(q)];
newdat = R*dat;
