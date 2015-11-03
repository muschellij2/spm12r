function biname = nii_binarize (P, func);
% input is grayscale image (continuous), output image created that is black and white (binary)
%   P : list of images
%   func: function to perform: 
%          -1: zero values more than minimum intensity
%          +1: zero values less than the maximum intensity
%          else zero values greater than or equal to the mean intensity
% The image Max and Min are used to calculate the intensity midpoint (Min+(Max-Min)/2);
%  Any voxel below this value is set to zero, else set to one
%  Otsu's method would be an alternative to determine midpoint...
% Example 
%   nii_binarize('C:\dir\img.nii');


if nargin <1 %no files
 P = spm_select(inf,'image','Select images to binarize');
end;

if nargin < 2 %no files
    func = 0;
end;
    
for i=1:size(P,1)
  %load image
  ref = deblank(P(i,:));
  [pth,nam,ext] = spm_fileparts(ref);
  Vin = spm_vol(ref);
  XYZ = spm_read_vols(Vin);
  %find min and max
  mx = max(max(max(XYZ(:,:,:,:)))); 
  mn = min(min(min(XYZ(:,:,:,:)))); 
  if (mx == mn) 
 	fprintf('nii_binarize error: no intensity variability in image %s.\n',Vin.fname);
	return;  
  end;
  biname = fullfile(pth,['b' nam ext]);
  XYZbin = zeros(size(XYZ));
  if func == -1      
    tmp      = find((XYZ)> mn);
    XYZbin(tmp) = 1;
    fprintf('%s has %d voxels greater than the minimum intensity of %f \n',biname, length(tmp),mn);
  elseif func == 1
    tmp      = find((XYZ)== mx);
    XYZbin(tmp) = 1;
    fprintf('%s has %d voxels with the maximum intensity of %f \n',biname, length(tmp), mx);
  else
    mid = mn + ((mx-mn)/2);
    tmp      = find((XYZ)>= mid);
    XYZbin(tmp) = 1;
    fprintf('%s has %d voxels with intensities of at least the mean (%f)\n',biname, length(tmp), mid);
  end;
  Vin.fname = biname;
  spm_write_vol(Vin,XYZbin);
end
