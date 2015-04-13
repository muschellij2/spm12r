function nii_zeronan(V);
%Voxels with NaN's are replaced with zero, output has 'z' prefix
% P : name[s] of image[s] (optional)
%
%http://en.wikibooks.org/wiki/SPM/Programming_intro
% http://blogs.warwick.ac.uk/nichols/entry/zero_nans_in/

if nargin<1, V = spm_select(inf,'image','Select image[s] to extract'); end
for i=1:size(V,1)
  fnm = deblank(V(i,:));
  [pth bnm ext] = spm_fileparts(fnm);
    VI = spm_vol(fnm);
    VO = VI; % copy input info for output image
    VO.fname = fullfile(pth, ['z' bnm ext]);  
    img = spm_read_vols(VI);
    img(isnan(img)) = 0; % use ~isfinite instead of isnan to replace +/-inf with zero
    spm_write_vol(VO,img);
end;
