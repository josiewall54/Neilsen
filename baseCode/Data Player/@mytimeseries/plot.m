function [linehandles, startview, stopview] = plot(myts, varargin)
% function [linehandles, startview, stopview] = plot(myts)
% function to plot an myts object
%

dat = myts.Data;

times = myts.Time;

linehandles = plot_matrix(dat,times);
startview = 1;
stopview = length(dat);


