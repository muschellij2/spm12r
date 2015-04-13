function result = nii_minnotzero(V);
%Returns minimum non-zero number
% V : name of image (optional)
%Example
% minnotzero('zscore.nii');

if nargin<1, V = spm_select(1,'image','Select image'); end

hdr = spm_vol(V);
img = spm_read_vols(hdr);
img(isnan(img)) = 0; % zero not-a-numbers
img(img == 0) = inf; %set all zeros to infinity
result = min(img(:));
fprintf('minimum non-zero value in %s is %f\n',V,result);


