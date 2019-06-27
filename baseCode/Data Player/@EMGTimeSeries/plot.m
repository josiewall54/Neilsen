function [linehandles, startview, stopview] = plot(ets, varargin)

[linehandles, startview, stopview] = plot@SubsetTimeSeries(ets,varargin{:});

midsamp = mean([startview stopview]);
nPulse = ets.getPulseFromSample(midsamp);
title(['Npulse = ' num2str(nPulse)]);
