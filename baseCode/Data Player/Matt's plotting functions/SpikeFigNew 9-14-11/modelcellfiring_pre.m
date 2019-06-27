function y = modelcellfiring_pre(angmag,para)
% para(1:3) have the gain, the preferred phase and the variability
% para(4:,...) have the magnitude dependence

ang = angmag(1,:);
mag = angmag(2:end,:);

t1 = para(1)/(sqrt(para(3)*2*pi));
dang = mod(ang-para(2),2*pi);
t = rem(dang+pi,2*pi);
t(t<0) = t(t<0) +2*pi;
dang = t-pi;
y = t1*exp(-(dang.^2)/(2*para(3)));  % this is the angular dependence

y = (para(4)*mag(1,:) + para(5)*mag(2,:)).*y + para(6)*mag(1,:)+para(7)*mag(2,:);

