function nii_img1mat2 (file1, file2, outname);
% Create version on file1 that has file2's spatial transformation matrix
%  file1 = image to modify
%  file2 = image that donates a transformation matrix
%  outname = name of modified image [optional]
% Example
%   nii_mean('C:\ct\script\xwsctemplate_final.nii',3);

if nargin <1 %no file1 specified
 file1 = spm_select(1,'image','Select image to change');
end;
if nargin <2 %no file2 specified
 file2 = spm_select(1,'image','Select image to donate matrix');
end;
if nargin <3 %no output specified
    [pth,nam,ext] = spm_fileparts(file1);
  	outname = fullfile(pth,['c',  nam, ext]);
end;

oh = spm_vol(file1); %output header
dh = spm_vol(file2); %donor header
oh.private.mat = dh.private.mat; 
oh.private.mat0 = dh.private.mat0; 
oh.mat = dh.mat;
o = spm_read_vols(oh);%Output image
oh.fname = outname;  
spm_write_vol(oh,o);