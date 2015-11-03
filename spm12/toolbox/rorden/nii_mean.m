function nii_mean = nii_mean (P, meanname);
% Given images P, generates an average image
%  P = filenames to average (optional)
%       if not specified, dialog prompts user to specify images 
%  meanname = filename of output (optional)
%       if not specified, prefix 'mean' appended to first filename
%
% Example
%   nii_mean('C:\ct\script\xwsctemplate_final.nii',3);

if nargin <1 %no files
 P = spm_select(inf,'image','Select images to average');
end;

if size(P,1) < 2 
niii_newseg	warning('nii_mean error: At least 2 images must be selected.');
end;

v = spm_vol(deblank(P(1,:)));
ave = spm_read_vols(v);

for i=2:size(P,1)
     v = spm_vol(deblank(P(i,:)));
     new = spm_read_vols(v);  
 	ave = ave + new;
end;
 
ave = ave / size(P,1);

if nargin <2 %no output name specified....
    [pth,nam,ext, vol]=spm_fileparts(deblank(P(1,:)));
    v.fname = fullfile(pth,['mean',  nam, ext]);
else
    v.fname = meanname;
end;
v.descrip = ['meanof' int2str(size(P,1)) ];
    
spm_write_vol(v,ave);