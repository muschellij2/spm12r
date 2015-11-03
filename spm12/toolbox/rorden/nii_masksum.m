function [result] = nii_masksum (Img, Mask);
% Sum intensity for all voxels in Img that are nonzero in Mask
%  Img = Input image (typically continuous) 
%  Mask = Masking region of interest (typically binary))
% Example
%   nii_sum('c1T1.nii','IPS.nii');

if nargin <1 %no files
 Img = spm_select(1,'image','Select intensity volume');
end;
if nargin <2 %no files
 Mask = spm_select(1,'image','Select masking volume');
end;

hdr = spm_vol(deblank(Img));
i = spm_read_vols(hdr);

hdr = spm_vol(deblank(Mask));
m = spm_read_vols(Mask);
result = mean(i(m ~= 0));
fprintf('voxels in %s that are not masked in %s have a mean intensity of %f\n', Img, Mask, result);
