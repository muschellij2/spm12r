function nii_test (P);
%Tests some of the other 'nii_' functions
% Example
%   nii_test ('C:\dir\image.nii');

if nargin <1 %no files
 P = spm_select(inf,'image','Select images to test');
end;

 ref = deblank(P(1,:));
 nii_8bit(ref);
 nii_16bit(ref);
 nii_binarize(ref);
 nii_c2h(ref);
 nii_centerinten(ref);
 nii_ctnorm(ref);
 nii_filedir_exists(ref);
 nii_h2c(ref);
 nii_intentranslate(ref, 0.5);
 nii_maxinten(ref);
 nii_midline(ref);
 nii_mirror(ref);
 nii_mrnorm(ref);
 nii_nii2voi(ref);
 nii_norm_linear(ref);
 nii_render(ref);
 nii_resize_img(ref,[2 2 2],[  -90 -126  -72;  90   90  108],false);
 nii_reslice1mm(ref);
 nii_smooth(ref);
 nii_smoothmask(ref);
 nii_smoothmaxinten(ref);
 nii_thresh_hi(ref,0.5);
 nii_thresh_lo(ref,0.5);

