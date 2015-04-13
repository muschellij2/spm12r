function nii_modulate(ai,bi);
%Multiply voxels in image ai with corresponding voxels in bi

if nargin <1 %no gray
 ai = spm_select(1,'image','Select gray matter volume');
end;
if nargin <2 %no white matter
 bi = spm_select(1,'image','Select white matter volume');
end;


if ischar(ai), ai = spm_vol(ai); end;
if ischar(bi), bi = spm_vol(bi); end;

%next lines make a brain render...
a = spm_read_vols(ai);
b = spm_read_vols(bi);

c=a.*b;
[pth,nam,ext]=fileparts(ai.fname);
ai.fname = fullfile(pth,['mod',  nam, ext]);
spm_write_vol(ai,c);

%NEXT LINES CREATE BINARY BRAIN MASK
%r=round(w);
%ri.fname = fullfile(pth,['s',  nam, ext]);
%spm_write_vol(ri,r);
