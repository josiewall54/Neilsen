function plotpara(para)
%function plotpara(para)
%  Function to plot the relevant features of the current parameter.

switch para(2)
case {1,2,12,13}  % it's a peak or a valley
   a = axis;
   plot([para(4) para(4)],[a(3) a(4)],'k');
   plot([para(5) para(5)],[a(3) a(4)],'k');
case {3,4,5,6}
   return
end