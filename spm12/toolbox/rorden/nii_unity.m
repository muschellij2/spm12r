function nii_unity(V);
%scale image for range 0..1
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
    VO.fname = fullfile(pth, ['u' bnm ext]);  
    img = spm_read_vols(VI);
    mx = max(img(:));
    mn = min(img(:));
    fprintf('%s has range of %f..%f, and will be rescaled to 0..1\n',fnm,mn,mx);   
    img = (img-mn)/mx;
    %img = img.*img; % <- sqr function emphasizes edges
    spm_write_vol(VO,img);
end;
