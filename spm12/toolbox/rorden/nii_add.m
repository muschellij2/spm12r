function nii_add(ai,bi);
%Sum two input images.

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
w = g+w;
mx=max(w(:));
w=w/mx;
if ischar(ri), ri = spm_vol(ri); end;
r = spm_read_vols(ri);
r=w.*r;
[pth,nam,ext]=fileparts(ri.fname);
ri.fname = fullfile(pth,['render',  nam, ext]);
spm_write_vol(ri,r);

%NEXT LINES CREATE BINARY BRAIN MASK
%r=round(w);
%ri.fname = fullfile(pth,['s',  nam, ext]);
%spm_write_vol(ri,r);
