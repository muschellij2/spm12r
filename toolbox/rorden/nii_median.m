function mdn= nii_median (Filename, Maskname);
% Finds median voxels of image V that are included in the Mask
% V: Continuous image[s] used for median calculation
% Mask: (optional). list of mask image[s] - region used for peak
%
%Example
%  mdn = nii_median('brain.nii','mask.nii');
%  mdn = nii_median('MNI152_T1_2mm_brain.nii.gz	','mask.voi');

if (nargin < 1) %Filename not specified
   [Filename, pathname] = uigetfile({'*.nii;*.img;*.gz;*.voi';'*.*'},'Select the Image'); 
   Filename = fullfile(pathname, Filename);
end;
if (nargin < 2) %user did not specify a mask - request one...
   [Maskname, pathname] = uigetfile({'*.nii;*.img;*.gz;*.voi';'*.*'},'Select the Mask'); 
   Maskname = fullfile(pathname, Maskname);
end;
%load image
Filename = nii_ungz(Filename);
vi = spm_vol(Filename);
img = spm_read_vols(vi);
%load mask
Maskname = nii_ungz(Maskname);
vm = spm_vol(Maskname);
mask = spm_read_vols(vm);
% make mask binary...
mn = min(mask(:));
mask = (mask ~= mn);
imgmasked = img(mask);
%return result
format long;
mdn=median(imgmasked);
fprintf('%s has %d voxels, after masking with %s the remaining %d voxels have a median intensity of %f\n',Filename,length(img(:)), Maskname,length(imgmasked(:)),mdn);    