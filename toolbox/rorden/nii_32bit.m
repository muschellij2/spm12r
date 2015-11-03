function nii_32bit (P);
% convert a NIfTI image to 32-bit (single precision) floating point format
% based on a snippet by Kiyo Nemoto http://www.nemotos.net/?p=200
% Example
%   nii_32bit ('C:\ct\script\xwsctemplate_final.nii');

if nargin <1 %no files
 P = spm_select(inf,'image','Select images to convert');
end;
spm_jobman('initcfg');
for i=1:size(P,1)
  ref = deblank(P(i,:));
  [pth,nam,ext] = spm_fileparts(ref);
  odir = pth;
  cvt = ['d' nam '.nii'];
  spm_jobman('initcfg');
  matlabbatch{1}.spm.util.imcalc.input = {ref};
  matlabbatch{1}.spm.util.imcalc.output = cvt;
  matlabbatch{1}.spm.util.imcalc.outdir = {odir};
  matlabbatch{1}.spm.util.imcalc.expression = 'i1';
  matlabbatch{1}.spm.util.imcalc.options.dmtx = 0;
  matlabbatch{1}.spm.util.imcalc.options.mask = 0;
  matlabbatch{1}.spm.util.imcalc.options.interp = 1;
  matlabbatch{1}.spm.util.imcalc.options.dtype = 16;
  % uint8=2; int16=4; int32=8; float32=16; float64=64
  spm_jobman('run',matlabbatch);
end