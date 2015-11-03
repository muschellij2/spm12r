function coivox = nii_centerinten(V)
% This script attempts to return the 'Center of Intensity' for an image
%  Similar to 'center of mass' - for each dimension the intensity is summed
%  COI is the midpoint for the intensity
% Example
%   nii_centerinten('C:\dir\img.nii');

coivox = zeros(1,3); %translate 0mm in X,Y,Z

%in case no files specified
if nargin <1 %no files
 %V = 'C:\irate\test\t1.nii';
 V = spm_select(inf,'image','Select image to midline align');
end

%extract filename 
[pth,nam,ext] = spm_fileparts(deblank(V(1,:)));
fname = fullfile(pth,[nam ext]);

%report if filename does not exist...
if (exist(fname) ~= 2) 
 	fprintf('NII_COI Error: unable to find image %s.\n',fname);
	return;  
end;

%load hdrer
fhdr = spm_vol([fname,',1']); 
if (fhdr.dim(1) < 1) or (fhdr.dim(2) < 1)
 	fprintf('NII_COI Error: not a 3D image %s.\n',fname);
	return;  
end;
%load image data
fdata = spm_read_vols(fhdr); 

xsum=zeros(1,fhdr.dim(1));
ysum=zeros(1,fhdr.dim(2));
zsum=zeros(1,fhdr.dim(3));
for Zi=1:fhdr.dim(3),
  img      = spm_slice_vol(fdata ,spm_matrix([0 0 Zi]),fhdr.dim(1:2),0);
  %make NaNs into zeros
  tmp      = find(isnan(img));
  img(tmp) = 0;
		
  px = 0; %image pixels
  for Yi=1:fhdr.dim(2),
  	for Xi=1:fhdr.dim(1),
       px = px+1;
       xsum(Xi) = xsum(Xi)+img(px);
       ysum(Yi) = ysum(Yi)+img(px);
       zsum(Zi) = zsum(Zi)+img(px);
  	end;
  end; %for Yi
end; %for Zi


coivox(1)= vectorcenter(xsum);
coivox(2)= vectorcenter(ysum);
coivox(3)= vectorcenter(zsum);

if sum(xsum) ~= 0 
 xsum = xsum/sum(xsum);
end;
if sum(ysum) ~= 0 
 xsum = ysum/sum(ysum);
end;
if sum(zsum) ~= 0 
 zsum = zsum/sum(zsum);
end;
dlmwrite('c:\x.tab', xsum', '\t');
dlmwrite('c:\y.tab', ysum', '\t');
dlmwrite('c:\z.tab', zsum', '\t');

return
%_______________________________________________________________________

%_______________________________________________________________________
function middle = vectorcenter(vectin);
%http://en.wikipedia.org/wiki/Center_of_mass
len = length(vectin);
middle = 0;
vect=vectin-min(vectin);
usum = sum(vect); %unweighted sum
if (usum == 0) 
  middle = (len)/2;
  return;
end;
wsum =0; %weighted sum
for i=1:len,
  wsum = wsum + (vect(i)*(i-0.5));
end; %for i
middle = wsum/usum;
return;
%_______________________________________________________________________
 
