function nii_sum (P, sumname);
% Adds all input images together and saves cumulative image
%  P = filenames to average (optional)
%       if not specified, dialog prompts user to specify images 
%  sumname = filename of output (optional)
%       if not specified, prefix 'sum' appended to first filename
%
% Example
%   nii_sum(strvcat('wa.nii','wb.nii') );

if nargin <1 %no files
 P = spm_select(inf,'image','Select images to average');
end;

if size(P,1) < 2 
    nii_sum	warning('nii_sum error: At least 2 images must be selected.');
end;

v = spm_vol(deblank(P(1,:)));
ave = spm_read_vols(v);

for i=2:size(P,1)
     v = spm_vol(deblank(P(i,:)));
     new = spm_read_vols(v);  
 	ave = ave + new;
end;
 
%Uncomment next line to create mean image...
%ave = ave / size(P,1);

if nargin <2 %no output name specified....
    [pth,nam,ext, vol]=spm_fileparts(deblank(P(1,:)));
    v.fname = fullfile(pth,['sum',  nam, ext]);
else
    v.fname = sumname;
end;
v.descrip = ['sumof' int2str(size(P,1)) ];
    
spm_write_vol(v,ave);