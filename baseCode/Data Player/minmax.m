function mnmx = minmax(x)
% function mnmx = minmax(x)
%   Takes data in x and returns the mininum and the maximum.  If X is a
%   matrix, then it performs the same operation on each of the rows and
%   concatenates MN MX MN MX etc...
%

mn = min(x');
mx = max(x');
mnmx(1:2:length(mn)*2) = mn;
mnmx(2:2:length(mn)*2) = mx;

