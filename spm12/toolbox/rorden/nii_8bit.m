function nii_8bit (P);
% uses SPM8 routines to downsample a NIfTI image to 8-bit precision
% based on a snippet by Kiyo Nemoto http://www.nemotos.net/?p=200
% Example
%   nii_8bit ('C:\dir\image.nii');

if nargin <1 %no files
 P = spm_select(inf,'image','Select images to convert');
end;

spm_jobman('initcfg');
for i=1:size(P,1)
  ref = deblank(P(i,:));
ref = deblank(P(i,:));
  [pth,nam,ext] = spm_fileparts(ref);
  odir = pth;
  cvt = ['d' nam '.nii'];
  matlabbatch{1}.spm.util.imcalc.input = {ref};
  matlabbatch{1}.spm.util.imcalc.output = cvt;
  matlabbatch{1}.spm.util.imcalc.outdir = {odir};
  matlabbatch{1}.spm.util.imcalc.expression = 'i1';
  matlabbatch{1}.spm.util.imcalc.options.dmtx = 0;
  matlabbatch{1}.spm.util.imcalc.options.mask = 0;
  matlabbatch{1}.spm.util.imcalc.options.interp = 1;
  matlabbatch{1}.spm.util.imcalc.options.dtype = 2;
  % uint8=2; int16=4; int32=8; float32=16; float64=64
  spm_jobman('run',matlabbatch);
end