function nii_cropedges(fnm, shadownm);
%Create new version of image 'fnm' removing all edge row, columns slices that are completely zeros
% fnm : name of image to crop (optional)
% shadownm : name of image to be cropped based on fnm (optional)
%Examples
%  nii_cropedges('img.nii'); %create 'zimg.nii' with cropped edges
%  nii_cropedges('img.nii','mask.nii'); %estimate cropping based on img, apply to both images


if nargin<1, fnm = spm_select(1,'image','Select image to crop'); end
if nargin==1, shadownm = []; end
if nargin<1, shadownm = spm_select(1,'image','Select shadow images (optional)'); end

%read source image
VI = spm_vol(fnm);
img = spm_read_vols(VI);
%find edges of the source image
[x,y,z] = ind2sub(size(img),find(img));
xlo = min(x)-1; %indexed from 1
xhi = max(x);
ylo = min(y)-1;
yhi = max(y);
zlo = min(z)-1;
zhi = max(z);
VO = VI;
VO.dim(1) = xhi-xlo;
VO.dim(2) = yhi-ylo;
VO.dim(3) = zhi-zlo;
if VO.dim == VI.dim, fprintf('Unable to crop %s as image extends to the edges\n',fnm); return; end;
fprintf('%s input voxels %dx%dx%d, output voxels %dx%dx%d\n',fnm, VI.dim(1),VI.dim(2),VI.dim(3),VO.dim(1),VO.dim(2),VO.dim(3)); 
fprintf('WARNING: origin will not be updated. Please use DISPLAY to set location of anterior commissure\n');
%create cropped image
imgO = zeros(VO.dim(1),VO.dim(2),VO.dim(3));
for z = 1 : VO.dim(3)
       for y = 1 : VO.dim(2)
           for x = 1 : VO.dim(1)
               imgO(x,y,z)=img(x+xlo,y+ylo,z+zlo);
           end; %x
       end; %y
end; %z
%save image...
[pth nm ext] = spm_fileparts(fnm);
VO.fname = fullfile(pth, ['z' nm ext]);  
spm_write_vol(VO,imgO);
%create cropped shadow image
if length(shadownm) < 1, return; end
Vfnm.dim = VI.dim;
VI = spm_vol(shadownm);
if Vfnm.dim ~= VI.dim, fprintf('Unable to crop  shadow image %s as dimensions differ from %s\n', shadownm,fnm); return; end;
fprintf('Cropping  shadow image %s based on edges of %s\n', shadownm,fnm);
%create cropped image
img = spm_read_vols(VI);
for z = 1 : VO.dim(3)
       for y = 1 : VO.dim(2)
           for x = 1 : VO.dim(1)
               imgO(x,y,z)=img(x+xlo,y+ylo,z+zlo);
           end; %x
       end; %y
end; %z
[pth nm ext] = spm_fileparts(shadownm);
VO.fname = fullfile(pth, ['z' nm ext]);  
spm_write_vol(VO,imgO);





