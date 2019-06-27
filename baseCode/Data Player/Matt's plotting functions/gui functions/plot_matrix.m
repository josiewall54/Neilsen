function line_handles = plot_matrix(dat,times,varargin)
%	line_handles = plot_matrix(dat,times,ax)
%
%   Plots the NSAMP X NCHAN data contained in DAT in a single axis, which
%   each channel vertically displaced.  Plots the points at the TIMES sent
%   in.  Plots these all in the AXIS sent in.  Returns the handles to the lines that are created. 
%

if nargin == 2
    ax = gca;
else
    ax = varargin{1};
end

trplotsize = 1;  % the (virtual) size of each virtual sub window that the trace is to be plotted in

[nsamp, nchan] = size(dat);
line_handles = [];
    for i = 1:nchan
        y = nchan*trplotsize - (2*i-1)*trplotsize/2;  % position the zero level for the current trace
        line_handles(i) = plot(times,y+dat(:,i)','k');         % plot the trace
        set(line_handles(i),'tag',num2str(i));
        hold on
    end
    hold off
    axis([min(times) max(times) 0 nchan*trplotsize]);  % set the boundaries for the figure
