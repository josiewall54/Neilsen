function [Y,Xnew,Yact]=predMIMO4MCT(X,H,numsides,fs,Yact)
%function to compute the output of a MIMO system
%
%    USAGE:   Y=predMIMO(X,H,numsides,fs)
%
%
%    Y        : Columnwise outputs [y1 y2 ...] to the unknown system
%    X        : Columnwise inputs  [x1 x2 ...] to the unknown system
%    H        : the nonparametric filters between X and Y.
%    numsides : determine a causal (1 side) or noncausal 
%               (2 sides) response.
%    fs		  : Sampling rate (default=1)
%
% The  filter matrix, H needs to be organized in columns as:
%     H=[h11 h21 h31 ....;
%        h12 h22 h32 ....;
%        h13 h23 h33 ...;
%        ... ... ... ...]
%  Which represents the system:
%  y1=h11 + h12*x1 + h13*x2 + h14*x3 + ...     
%  y2=h21 + h22*x1 + h23*x2 + h24*x3 + ...     
%  y3=h31 + h32*x1 + h33*x2 + h34*x3 + ...    
%  ... 

% EJP April 1997, CE October 2013

mxy = H(1,:);
H = H(2:end,:);

[numpts,Nx]=size(X);
[nr,Ny]=size(H);
fillen=nr/Nx;

if (rem(nr,Nx) ~= 0)
   disp('Input size does not match dimensions of filter matrix')
   return
end
%Allocate memory for the outputs
Y=zeros(numpts,Ny);

% predict separately for each block of data
nanind = find(isnan(X(:,1)));  % these are the indices where it is NaN
nsegments = length(nanind) + 1;  % number of discontinuous segments in the data

naninduse = [0 nanind' numpts+1];  % these give the indices to use for each segment of data
for ii = 1:nsegments
    segind = (naninduse(ii)+1):(naninduse(ii+1)-1);  % the indices for the ii'th segment 
    for i=1:Ny
        for j=1:Nx
            Y(segind,i)=Y(segind,i)+filter22(H(1+(j-1)*fillen:j*fillen,i),X(segind,j),numsides)/fs;
        end
        %add back means:
        Y(segind,i) = Y(segind,i)+mxy(i);
    end
end
Y(nanind,:) = NaN;

if nargout>1
	if numsides==2
		skip=(fillen-1)/2;
		Y=Y(skip+1:numpts-skip,:);
		Xnew=X(skip+1:numpts-skip,:);
		Yact=Yact(skip+1:numpts-skip,:);
	else
		Y=Y(fillen:numpts,:);
		Xnew=X(fillen:numpts,:);
		Yact=Yact(fillen:numpts,:);
	end
end
		
