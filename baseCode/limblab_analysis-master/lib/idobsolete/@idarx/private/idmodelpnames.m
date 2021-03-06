function [Props,AsgnVals] = idmodelpnames
%PNAMES  All public properties and their assignable values
%
%   [PROPS,ASGNVALS] = PNAMES(M)  returns the list PROPS of
%   public properties of the object M (a cell vector), as well as
%   the assignable values ASGNVALS for these properties (a cell vector
%   of strings).  PROPS contains the true case-sensitive property names.
%   These include the public properties of M's parent(s).
%
%   See also  GET, SET.

%       Copyright 1986-2010 The MathWorks, Inc.


% IDMODEL properties
Props = {'Name';'Ts'; 'InputName' ; 'InputUnit'; 'OutputName'; ...
   'OutputUnit' ; 'TimeUnit'; 'ParameterVector' ;'PName'; 'CovarianceMatrix' ; ...
   'NoiseVariance' ; 'InputDelay'; 'Algorithm' ; ...
   'EstimationInfo' ; 'Notes' ; 'UserData'};

% Also return assignable values if needed
if nargout>1,
   AsgnVals = {'string';...
      'Scalar (sample time in seconds)'; ...
      'Nu-by-1 cell array of strings'; ...
      'Nu-by-1 cell array of strings'; ...
      'Ny-by-1 cell array of strings'; ...
      'Ny-by-1 cell array of strings'; ...
      'string';...
      'Np-by-1 vector';...
      'Np-by-1 cell array of strings'; ...
      'Np-by-Np matrix';...
      'Ny-by-Ny matrix';...
      'Nu-by-1 vector';...
      'Structure containing algorithm details';...
      'Structure containing estimation results';...
      'Array or cell array of strings'; ...
      'Arbitrary'};
end
