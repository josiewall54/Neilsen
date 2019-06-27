classdef mytimeseries < timeseries

    properties
        dataInfo
    end
   
    methods
                function myts = mytimeseries(varargin)
%                     if nargin == 1
% %                         myts = varargin{1};
%                     elseif nargin == 0
                        myts = myts@timeseries();
                        myts.dataInfo = [];
%                     end
                end
                
     function [linehandles, startview, stopview] = plot(myts, varargin)
            % function [linehandles, startview, stopview] = plot(myts, time1,time2,nsamp1,nsamp2)
            % function to plot an myts object according to the view defined in nsamp1
            % and nsamp2 - checks the requested view against it's own properties and
            % against the screen where it's being plotted and the displays things
            % somewhat intelligently
            %

                dat = get(myts,'Data');
                times = get(myts,'Time');

            if (nargin > 1) & (nargin < 4)  % if they sent in times, indicate the view to show
                ntime1 = varargin{1};
                ntime2 = varargin{2};
                ind = find((times >= ntime1) & (times <= ntime2));
                dat = dat(ind,:);
                times = times(ind);
                startview = ind(1);
                stopview = ind(end);

            elseif (nargin > 3)       % they've sent in sample numbers
                nsamp1 = max([1 varargin{3}]);
                nsamp2 = min([length(dat) varargin{4}]);
                dat = dat(nsamp1:nsamp2,:);
                times = times(nsamp1:nsamp2);
                startview = nsamp1;
                stopview = nsamp2;
            end

            linehandles = plot_matrix(dat,times);

        end

        function myts = set(myts,varargin)
            if strcmp(varargin{1},'dataInfo')
                myts.dataInfo = varargin{2};
            else
%                 myts = copy(myts);
                myts = set@timeseries(myts,varargin{:});
            end
        end
        
        function val = get(myts,varargin)
            if strcmp(varargin{1},'dataInfo')
                val = myts.dataInfo;
            elseif strcmp(varargin{1},'mytimeseries')
                val = myts;
            elseif strcmp(varargin{1},'data')
                val = get@timeseries(myts,'Data');
                if nargin == 3
                    t_limits = varargin{2};
                    Times = get@timeseries(myts,'Time');
                    useind = find((Times > t_limits(1)) & (Times < t_limits(2)));
                    val = val(useind,:);
                end
            elseif strcmp(varargin{1},'time')
                val = get@timeseries(myts,'Time');
                if nargin == 3
                    t_limits = varargin{2};
                    Times = get@timeseries(myts,'Time');
                    useind = find((Times > t_limits(1)) & (Times < t_limits(2)));
                    val = val(useind,:);
                end
            else
                val = get@timeseries(myts,varargin{:});
            end
        end

        function varargout = size(myts,varargin)
          [nsamp,nchan] = size(myts.Data);
          
          out1 = nsamp;
          out2 = nchan;
          if nargin == 2
                if varargin{1} == 1
                    out1 = nsamp;
                elseif varargin{1} == 2
                    out1 = nchan;
                end
          end
          
          varargout{1} = out1;
           if nargout == 2
               varargout{2} = out2;
           end
      end
      
        
    end
end