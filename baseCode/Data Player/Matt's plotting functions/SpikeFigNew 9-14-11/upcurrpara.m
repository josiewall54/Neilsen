function plist = upcurrpara(plist,paran,pn,p)
%function plist = upcurrpara(plist,paran,pn)
%   Function to change the control parameters for parameter extraction
%   PLIST is the parameter list in the data structure, PARAN is the
%   currently selected parameter, PN is the control parameter being
%   edited, P is the new value.  Actions taken are dependent on the
%   parameter being edited.


switch plist(paran,2)
case 1  % it's a Peak
   plist(paran,pn+3) = p;  % change the Peak parameters
   plist(paran+2,pn+3) = p;  % also change the Time to Peak value
   if pn == 1;   % change the first Time Peak to Valley control  
      plist(paran+4,pn+3) = p;  
   end
   plist(paran+6,pn+3) = p;  % change the spike width parameter
case 2  % it's a Valley 
   plist(paran,pn+3) = p;  % change the Valley parameter
   plist(paran+2,pn+3) = p;  % also change the Time to Valley value
   if pn == 2;   % change the second Time Peak to Valley control  
      plist(paran+4,pn+3) = p;  
   end
case 3,4,5,6
   disp('specify changes for these parameters for Peak or Valley')
case 7   % it's spike width
   if pn == 1
      plist(paran,pn+5) = p;   % you can use either button to 
   else
      plist(paran,pn+4) = p;   % to set the voltage for spike width
   end   
   disp('voltage crossing set for spike width')
case 8,9,10,11
   disp('nothing to be updated for pca')
case 12  % it's an arbitrary Peak
   plist(paran,pn+3) = p;  % change the Peak parameters
   plist(paran+2,pn+3) = p;  % also change the Time to Peak value
   if pn == 1;   % change the first Time Peak to Valley control  
      plist(paran+4,pn+3) = p;  
   end
   plist(paran+6,pn+3) = p;  % change the spike width parameter
case 13  % it's an arbitrary Valley
   plist(paran,pn+3) = p;  % change the Peak parameters
   plist(paran+2,pn+3) = p;  % also change the Time to Peak value
   if pn == 1;   % change the first Time Peak to Valley control  
      plist(paran+4,pn+3) = p;  
   end
   plist(paran+6,pn+3) = p;  % change the spike width parameter
case 14  % it's a Valley 
   plist(paran,pn+3) = p;  % change the Valley parameter
   plist(paran+2,pn+3) = p;  % also change the Time to Valley value
   if pn == 2;   % change the second Time Peak to Valley control  
      plist(paran+4,pn+3) = p;  
   end
end
