function nii_subtract (P,N, outname);
% Adds all 'P'ositive images, Subtracts all 'N'egative images: saves result
%  P = filenames to add (optional)
%  N = filenames to subtract (optional)
%  outname = filename of output (optional)
%       if not specified, prefix 'sum' appended to first filename
%
% Example
%   nii_subtract('wa.nii','wb.nii' );

if nargin <1 %no Positive files
 P = spm_select(inf,'image','Select images to add');
end;

if nargin <2 %no Negative files
 N = spm_select(inf,'image','Select images to subtract');
end;


v = spm_vol(deblank(P(1,:)));
ave = spm_read_vols(v);

for i=2:size(P,1)
     v = spm_vol(deblank(P(i,:)));
     new = spm_read_vols(v);  
 	ave = ave + new;
end;
 
for i=1:size(N,1)
     v = spm_vol(deblank(N(i,:)));
     new = spm_read_vols(v);  
 	ave = ave - new;
end;

if nargin < 3 %no output name specified....
    [pth,nam,ext, vol]=spm_fileparts(deblank(P(1,:)));
    v.fname = fullfile(pth,['sub',  nam, ext]);
else
    v.fname = sumname;
end;
v.descrip = [ int2str(size(P,1)) ' - ' int2str(size(N,1))];
    
spm_write_vol(v,ave);