function mivox = nii_maxinten(V)
% This script finds brightest voxel in 3D image
% it also returns the center of intensity for the rows and columns
% Assumes slices already resliced
%
% Example
%   nii_maxinten('C:\dir\img.nii');

mivox = zeros(1,3); %translate 0mm in X,Y,Z

%in case no files specified
if nargin <1 %no files
 %V = 'C:\irate\test\rmeanfmri.nii';
 V = spm_select(inf,'image','Select image to midline align');
end

%extract filename 
[pth,nam,ext] = spm_fileparts(deblank(V(1,:)));
fname = fullfile(pth,[nam ext]);

%report if filename does not exist...
if (exist(fname) ~= 2) 
 	fprintf('NII_MAXINTEN Error: unable to find image %s.\n',fname);
	return;  
end;

%load hdr
fhdr = spm_vol([fname,',1']); 
if (fhdr.dim(1) < 1) or (fhdr.dim(2) < 1)
 	fprintf('NII_MAXINTEN Error: not a 3D image %s.\n',fname);
	return;  
end;
%load image data
fdata = spm_read_vols(fhdr); 

xsum=zeros(1,fhdr.dim(1));
ysum=zeros(1,fhdr.dim(2));
zsum=zeros(1,fhdr.dim(3));
for Zi=1:fhdr.dim(3),
  img      = spm_slice_vol(fdata ,spm_matrix([0 0 Zi]),fhdr.dim(1:2),0);
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
mivox(1)= vectormax(xsum);
mivox(2)= vectormax(ysum);
mivox(3)= vectormax(zsum);
return
%_______________________________________________________________________

%_______________________________________________________________________
function maxindex = vectormax(vect);
[C,I] = max(vect);
maxindex = mean(I);
return;
%_______________________________________________________________________

